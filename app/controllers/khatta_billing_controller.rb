class KhattaBillingController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[add_payment remove_payment set_amount]

  # A running-balance ledger per contractor:
  #   Charge  = embroidery bills          (we owe the contractor)
  #   Claim   = his damaged suits         (his mistake → HE owes us → SUBTRACTS)
  #   Paid    = payments we made          (SUBTRACTS)
  #   Balance = Charge − Claim − Paid     (what we still owe him)
  def index
    disp  = KhattaEmb.dispatches
    pays  = KhattaPayment.all.group_by(&:contractor)
    rates = CostCard.all.each_with_object({}) { |c, h| h[c.code] = c.fabric_rate.to_f }   # per-metre fabric rate
    # Extra cloth issued to a real contractor (not Master) — he owes for it: metres × fabric rate
    adjs  = LotAdjustment.where.not(contractor: LotAdjustment::MASTER)
                         .includes(:fabric_lot, :fabric_lot_color).group_by { |a| a.contractor.to_s }
    names = (disp.map(&:contractor) + pays.keys + adjs.keys).map { |c| c.to_s }.reject(&:blank?).uniq

    @ledgers = names.map do |contractor|
      rows = disp.select { |d| d.contractor.to_s == contractor }
      entries = []
      # Charge: embroidery bills
      rows.each do |d|
        next unless d.bill.positive?
        entries << { date: d.last_date, detail: "Bill — #{d.design} · Laat ##{d.laat}", charge: d.bill, claim: 0, cloth: 0, paid: 0,
                     kind: "bill", emb_id: d.emb&.id, overridden: d.bill_overridden? }
      end
      # Claim: contractor's damaged suits — HE owes us, so it deducts from what we owe him
      rows.each do |d|
        next unless d.claim_amount.positive?
        entries << { date: d.last_date, detail: "Claim — #{d.claim_suits} damaged · #{d.design}", charge: 0, claim: d.claim_amount, cloth: 0, paid: 0,
                     kind: "claim", emb_id: d.emb&.id, overridden: d.claim_overridden? }
      end
      # Stitch claim: suits ruined during stitching — contractor owes (Total − CM), and their embroidery
      # payment for those suits is already removed from the Bill above.
      rows.each do |d|
        next unless d.stitch_claim_amount.positive?
        entries << { date: d.last_date, detail: "Stitch claim — #{d.stitch_claim_suits} ruined · #{d.design}", charge: 0, claim: d.stitch_claim_amount, cloth: 0, paid: 0,
                     kind: "claim", emb_id: d.emb&.id }
      end
      # Cloth Claim: extra cloth issued to him = metres × fabric rate (from that article's cost card)
      Array(adjs[contractor]).each do |a|
        metres = a.gazana.to_f
        next unless metres.positive?
        cost = (metres * rates[a.design].to_f).round(2)
        entries << { date: a.date, detail: "Extra cloth — #{metres.to_i == metres ? metres.to_i : metres}m · #{a.design.presence || '—'}#{" · #{a.fabric_lot_color.name}" if a.fabric_lot_color} · Laat ##{a.fabric_lot&.laat_number}",
                     charge: 0, claim: 0, cloth: cost, paid: 0, kind: "cloth" }
      end
      # Paid: payments recorded
      Array(pays[contractor]).each do |p|
        entries << { date: p.paid_on, detail: (p.method_detail.presence || "Payment") + (p.notes.present? ? " · #{p.notes}" : ""),
                     charge: 0, claim: 0, cloth: 0, paid: p.amount.to_f, kind: "payment", id: p.id, payment: p }
      end

      # oldest first; on the same date show the bill (charge) before deductions
      entries.sort_by! { |e| [e[:date] || Date.new(1900, 1, 1), e[:kind] == "bill" ? 0 : 1] }
      bal = 0.0
      entries.each { |e| bal += e[:charge] - e[:claim] - e[:cloth] - e[:paid]; e[:balance] = bal.round(2) }

      {
        contractor: contractor,
        entries:    entries,
        charge:     entries.sum { |e| e[:charge] },
        claim:      entries.sum { |e| e[:claim] },
        cloth:      entries.sum { |e| e[:cloth] },
        paid:       entries.sum { |e| e[:paid] },
        balance:    bal.round(2),
        pending_suits: rows.sum { |d| [d.pending, 0].max }
      }
    end.select { |l| l[:entries].any? }.sort_by { |l| -l[:balance] }

    @tot_charge  = @ledgers.sum { |l| l[:charge] }
    @tot_claim   = @ledgers.sum { |l| l[:claim] }
    @tot_cloth   = @ledgers.sum { |l| l[:cloth] }
    @tot_paid    = @ledgers.sum { |l| l[:paid] }
    @tot_balance = @ledgers.sum { |l| l[:balance] }
    @parties     = names.sort
  end

  # Create OR edit a payment (same modal form; an existing id means edit).
  def add_payment
    editing = params[:payment_id].present?
    pay = editing ? KhattaPayment.find(params[:payment_id]) : KhattaPayment.new
    pay.assign_attributes(contractor: params[:contractor], amount: params[:amount],
                          paid_on: params[:paid_on].presence || (pay.paid_on || Date.current),
                          method_detail: params[:method_detail], notes: params[:notes])
    pay.proof.attach(params[:proof]) if params[:proof].present?
    pay.save!
    redirect_to khatta_billing_path,
                notice: editing ? "Payment updated." : "Payment recorded for #{params[:contractor]} — Rs #{params[:amount]}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to khatta_billing_path, alert: e.record.errors.full_messages.to_sentence
  end

  def remove_payment
    KhattaPayment.find(params[:id]).destroy
    redirect_to khatta_billing_path, notice: "Payment removed."
  end

  # Override a fetched Charge or Claim amount (blank = revert to the computed value).
  def set_amount
    emb = KhattaEmb.find(params[:emb_id])
    val = params[:amount].to_s.strip
    val = val.blank? ? nil : val
    emb.update!(params[:field] == "claim" ? { claim_override: val } : { bill_override: val })
    redirect_to khatta_billing_path, notice: "#{params[:field] == 'claim' ? 'Claim' : 'Charge'} updated."
  end

  private

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Khatta (Billing)." unless current_user.can_see?("khatta_bill")
  end

  def block_view_only
    redirect_to khatta_billing_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
