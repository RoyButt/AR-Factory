class ProductionProgressController < ApplicationController
  before_action :require_login
  before_action :require_section

  def index
    @stage = params[:stage] == "handmade" ? "handmade" : "cutwork"
    @items = ProductionProgress.where(stage: @stage).includes(:fabric_lot, :production_sheet, :cutwork_party, :handmade_pass)
    @total_suits = @items.sum { |i| i.suits.to_i }
    @cutwork_parties = CutworkParty.all
    @default_cw_id = CutworkParty.first_created&.id
    @cut_rates = CostCard.all.each_with_object({}) { |c, h| h[c.code] = c.cut_work.to_f }
    if @stage == "handmade"
      @fresh   = @items.reject(&:handmade_pass)
      @passed  = @items.select(&:handmade_pass)
      @hand_parties  = HandmadeParty.all
      @hand_rates    = CostCard.all.each_with_object({}) { |c, h| h[c.code] = c.hand_made.to_f }
      @prod_persons  = ProductionParty.all
      @final_rates   = CostCard.all.each_with_object({}) { |c, h| h[c.code] = c.final_rate.to_f }
    end
  end

  # Generate a handmade pass (token) for a fresh item → moves it to Generated Pass.
  def generate_pass
    return head(:forbidden) if current_user.view_only?
    item = ProductionProgress.find(params[:id])
    rate = CostCard.find_by(code: item.design_code)&.hand_made.to_f
    pass = HandmadePass.find_or_initialize_by(production_progress_id: item.id)
    pass.assign_attributes(handmade_party_id: params[:handmade_party_id].presence, design_code: item.design_code,
                           laat: item.laat, suits: params[:suits].presence || item.suits,
                           rate: rate, adjustment: params[:adjustment].presence || 0,
                           pass_on: params[:pass_on].presence || Date.current, notes: params[:notes])
    pass.save!
    redirect_to handmade_pass_path(pass), notice: "Pass #{pass.token} generated."
  end

  # Printable pass (half A4).
  def pass
    @pass = HandmadePass.find(params[:id])
    render layout: "print"
  end

  # Edit a generated pass's rate adjustment (+/−) from the Generated Pass table.
  def set_pass_adjustment
    return head(:forbidden) if current_user.view_only?
    pass = HandmadePass.find(params[:id])
    pass.update!(adjustment: params[:adjustment].presence || 0)
    dest = params[:return_to] == "handwork_billing" ? handwork_billing_path : handmade_progress_path
    redirect_to dest, notice: "Adjustment saved for #{pass.token} — rate now #{helpers.rs(pass.effective_rate)}."
  end

  # Handmade (final step): claim ruined suits by colour → charge the chosen production person.
  # Cost = claimed suits × the design's cost-card final rate; deducted from that person's account.
  def claim_suit
    return head(:forbidden) if current_user.view_only?
    item  = ProductionProgress.find(params[:id])
    lines = parse_claim_lines
    party = ProductionParty.find_by(id: params[:production_party_id])
    if lines.empty? || party.nil?
      return redirect_to handmade_progress_path, alert: "Pick a person and at least one colour with a suit count."
    end
    rate  = item.final_rate
    suits = lines.sum { |l| l[:suits] }
    ProductionClaim.create!(production_progress_id: item.id, handmade_pass_id: item.handmade_pass&.id,
                            production_party_id: party.id, design_code: item.design_code, laat: item.laat,
                            rate: rate, suits: suits, amount: (suits * rate).round(2),
                            colors: lines.map { |l| { color_id: l[:color_id], name: l[:color_name], suits: l[:suits] } },
                            claimed_on: Date.current)
    redirect_to handmade_progress_path,
                notice: "Claimed #{suits} ruined suits — #{helpers.rs((suits * rate).round(2))} deducted from #{party.name}."
  end

  # Assign (or clear) the cutwork party for a progress item → who does the cutwork.
  def assign
    return head(:forbidden) if current_user.view_only?
    item = ProductionProgress.find(params[:id])
    item.update!(cutwork_party_id: params[:cutwork_party_id].presence)
    redirect_to(item.stage == "handmade" ? handmade_progress_path : cutwork_progress_path,
                notice: "Assigned to #{item.cutwork_party&.name || 'unassigned'}.")
  end

  # Save a cutwork row's rate adjustment (+/−). Per-row, defaults to 0, doesn't touch other rows.
  def set_adjustment
    return head(:forbidden) if current_user.view_only?
    item = ProductionProgress.find(params[:id])
    item.update!(adjustment: params[:adjustment].presence || 0)
    dest = params[:return_to] == "cutwork_billing" ? cutwork_billing_path : cutwork_progress_path
    redirect_to dest, notice: "Adjustment saved for #{item.design_code} — rate now #{helpers.rs(item.effective_cutwork_rate)}."
  end

  private
  def require_section
    key = params[:stage] == "handmade" ? "handmade_prog" : "cutwork_prog"
    redirect_to dashboard_path, alert: "You don't have access to this page." unless current_user.can_see?(key)
  end
end
