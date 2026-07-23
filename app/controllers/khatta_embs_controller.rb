class KhattaEmbsController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[add_return complete_delivery set_rate set_claim update_return remove_return delete_returns]

  # All embroidery dispatches are auto-fetched from the fabric lots; the user only adds returns.
  def index
    all = KhattaEmb.dispatches
    @filter_parties = all.map(&:contractor).compact.uniq.sort
    @filter_designs = all.map(&:design).compact.uniq.sort
    @filter_laats   = all.map(&:laat).compact.uniq.sort

    rows = all
    if params[:q].present?
      q = params[:q].to_s.downcase
      rows = rows.select { |d| "#{d.laat} #{d.contractor} #{d.design}".downcase.include?(q) }
    end
    rows = rows.select { |d| d.contractor == params[:contractor] } if params[:contractor].present?
    rows = rows.select { |d| d.design == params[:design] }         if params[:design].present?
    rows = rows.select { |d| d.laat.to_s == params[:laat].to_s }   if params[:laat].present?
    rows = rows.select { |d| d.pending.positive? }                 if params[:status] == "pending"
    rows = rows.select { |d| d.pending <= 0 }                      if params[:status] == "complete"
    rows = rows.select { |d| d.returned.positive? }                if params[:status] == "started"
    @dispatches = rows

    # master "still out" list — always the full outstanding picture, regardless of filters
    @pending = all.select { |d| d.pending.positive? }.sort_by { |d| -d.pending }
    @total_pending = @pending.sum(&:pending)

    # summary across the filtered rows
    @sum_sent     = rows.sum(&:suits_sent)
    @sum_returned = rows.sum(&:returned)
    @sum_pending  = rows.sum { |d| [d.pending, 0].max }
    @sum_bill     = rows.sum(&:bill)
    @sum_claim    = rows.sum(&:claim_amount)
    @sum_total    = rows.sum(&:total_bill)

    # group the (filtered) dispatches under their Laat, keeping lot order
    @by_laat = rows.group_by(&:lot)
  end

  # Record a return of suits against one dispatch (find/create its ledger row, add a delivery).
  def add_return
    lot   = FabricLot.find(params[:fabric_lot_id])
    suits = params[:suits].to_i
    if suits <= 0
      return redirect_to khatta_embs_path, alert: "Enter a suits quantity greater than 0."
    end
    on = params[:delivered_on].presence || Date.current
    emb = KhattaEmb.find_or_initialize_by(fabric_lot_id: lot.id, contractor: params[:contractor], design_code: params[:design_code])
    emb.suits_sent = params[:suits_sent]
    emb.returned_on = on
    emb.save!
    emb.khatta_deliveries.create!(suits: suits, delivered_on: on)
    redirect_to khatta_embs_path, notice: "Return recorded — #{suits} suits from #{params[:contractor]} (#{params[:design_code]})."
  end

  # Mark a whole dispatch as fully delivered — top up returns to equal suits sent.
  def complete_delivery
    lot = FabricLot.find(params[:fabric_lot_id])
    emb = KhattaEmb.find_or_initialize_by(fabric_lot_id: lot.id, contractor: params[:contractor], design_code: params[:design_code])
    emb.suits_sent = params[:suits_sent].to_i
    emb.returned_on = Date.current
    emb.save!
    remaining = emb.suits_sent - emb.returned
    emb.khatta_deliveries.create!(suits: remaining, delivered_on: Date.current) if remaining.positive?
    redirect_to khatta_embs_path, notice: "✓ #{params[:contractor]} marked fully delivered — all #{emb.suits_sent} suits of #{params[:design_code]}."
  end

  # Save an editable per-dispatch rate override (defaults from the cost card). Drives the Bill.
  def set_rate
    lot = FabricLot.find(params[:fabric_lot_id])
    emb = KhattaEmb.find_or_initialize_by(fabric_lot_id: lot.id, contractor: params[:contractor], design_code: params[:design_code])
    emb.suits_sent = params[:suits_sent]
    emb.returned_on ||= Date.current
    emb.rate = params[:rate].presence
    emb.save!
    redirect_to khatta_embs_path, notice: "Rate saved — Rs #{emb.rate.to_i}/suit for #{params[:contractor]} (#{params[:design_code]})."
  end

  # Record damaged suits as a claim — contractor pays for them (Final Rate − CM per suit).
  def set_claim
    lot = FabricLot.find(params[:fabric_lot_id])
    emb = KhattaEmb.find_or_initialize_by(fabric_lot_id: lot.id, contractor: params[:contractor], design_code: params[:design_code])
    emb.suits_sent = params[:suits_sent]
    emb.returned_on ||= Date.current
    emb.save!
    lines = parse_claim_lines
    emb.replace_claim_colors!("emb", lines)
    n = emb.reload.claim_suits.to_i
    msg = n.zero? ? "Cleared the claim for #{params[:contractor]} (#{params[:design_code]})." :
          "Claim saved — #{n} damaged suits across #{lines.size} colour#{'s' if lines.size != 1} for #{params[:contractor]} (#{params[:design_code]})."
    redirect_to khatta_embs_path, notice: msg
  end

  # Edit one logged return (change its suits / date). Zero suits removes it.
  def update_return
    d   = KhattaDelivery.find(params[:delivery_id])
    emb = d.khatta_emb
    suits = params[:suits].to_i
    if suits <= 0
      d.destroy
    else
      d.update!(suits: suits, delivered_on: params[:delivered_on].presence || d.delivered_on)
    end
    emb.destroy if emb.khatta_deliveries.reload.empty?
    redirect_to khatta_embs_path, notice: "Return updated."
  end

  # Remove a single return (delivery). If the ledger has no more returns, drop it too.
  def remove_return
    d = KhattaDelivery.find(params[:delivery_id])
    emb = d.khatta_emb
    d.destroy
    emb.destroy if emb.khatta_deliveries.reload.empty?
    redirect_to khatta_embs_path, notice: "Return removed."
  end

  # Delete ALL returns for one dispatch (resets it; unlocks the lot if it was the only return).
  def delete_returns
    emb = KhattaEmb.find(params[:id])
    label = "#{emb.contractor} (#{emb.design_code})"
    emb.destroy
    redirect_to khatta_embs_path, notice: "All returns removed for #{label}."
  end

  private

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Khatta (Emb)." unless current_user.can_see?("khatta_emb")
  end

  def block_view_only
    redirect_to khatta_embs_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
