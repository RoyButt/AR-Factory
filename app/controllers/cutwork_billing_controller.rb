class CutworkBillingController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[add_payment remove_payment]

  # Cutwork cost = Σ (suits × the design's Cutwork price from its cost card).
  def index
    rates = CostCard.all.each_with_object({}) { |c, h| h[c.code] = c.cut_work.to_f }
    @rows = ProductionProgress.where(stage: "cutwork").includes(:fabric_lot, :cutwork_party).map do |it|
      base = rates[it.design_code.to_s].to_f
      adj  = it.adjustment.to_f
      rate = (base + adj).round(2)
      { id: it.id, date: it.created_at.to_date, laat: it.laat, design: it.design_code, suits: it.suits.to_i,
        base_rate: base, adjustment: adj, rate: rate, amount: (it.suits.to_i * rate).round(2),
        colours: it.colours, party: it.cutwork_party&.name, party_id: it.cutwork_party_id }
    end.sort_by { |r| [-(r[:date].to_time.to_i), r[:design].to_s] }

    @total_cutwork = @rows.sum { |r| r[:amount] }.round(2)
    @total_suits   = @rows.sum { |r| r[:suits] }
    @payments      = CutworkPayment.includes(:cutwork_party).all
    @total_paid    = @payments.sum { |p| p.amount.to_f }.round(2)
    @remaining     = (@total_cutwork - @total_paid).round(2)
    @parties       = CutworkParty.all
    @default_cw_id = CutworkParty.first_created&.id

    # per-party transparency: who earned how much cutwork vs what we paid them
    paid_by_party = @payments.group_by(&:cutwork_party_id).transform_values { |ps| ps.sum { |p| p.amount.to_f } }
    earned_by_party = @rows.group_by { |r| r[:party_id] }.transform_values { |rs| rs.sum { |r| r[:amount] } }
    ids = (earned_by_party.keys + paid_by_party.keys).uniq
    @by_party = ids.map do |pid|
      name = pid ? (CutworkParty.find_by(id: pid)&.name || "—") : "Unassigned"
      earned = (earned_by_party[pid] || 0).round(2); paid = (paid_by_party[pid] || 0).round(2)
      { name: name, earned: earned, paid: paid, remaining: (earned - paid).round(2) }
    end.sort_by { |h| -h[:remaining] }
  end

  # Create OR edit a payment (a payment_id means edit).
  def add_payment
    editing = params[:payment_id].present?
    pay = editing ? CutworkPayment.find(params[:payment_id]) : CutworkPayment.new
    pay.assign_attributes(cutwork_party_id: params[:cutwork_party_id].presence, amount: params[:amount],
                          paid_on: params[:paid_on].presence || (pay.paid_on || Date.current),
                          method_detail: params[:method_detail], notes: params[:notes])
    pay.proof.attach(params[:proof]) if params[:proof].present?
    pay.save!
    redirect_to cutwork_billing_path, notice: editing ? "Payment updated." : "Cutwork payment recorded."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to cutwork_billing_path, alert: e.record.errors.full_messages.to_sentence
  end

  def remove_payment
    CutworkPayment.find(params[:id]).destroy
    redirect_to cutwork_billing_path, notice: "Payment removed."
  end

  private
  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Cutwork Billing." unless current_user.can_see?("cutwork_bill")
  end
  def block_view_only
    redirect_to cutwork_billing_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
