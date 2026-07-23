class ProductionSheetsController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[new create edit update destroy claim complete reopen]

  def index
    # earliest work-start (stitch_date) at top; fall back to created date
    @sheets = ProductionSheet.all.sort_by { |s| s.stitch_date || s.sheet_date || Date.new(1900, 1, 1) }
  end

  def new
    rows = Array.new(7) { "AR-" }
    rows[0] = params[:design] if params[:design].present?   # pre-fill first row (e.g. from Stitching → Prepare sheet)
    @sheet = ProductionSheet.new(sheet_date: Date.current, day: Date.current.strftime("%A"),
                                 rows: rows, values: {}, hidden_cols: ProductionSheet.last_hidden_cols)
    @parties = ProductionParty.all
    render :edit
  end

  def edit
    @sheet = ProductionSheet.find(params[:id])
    refresh_targets(@sheet) if @sheet.prepared?   # keep net-suit targets in sync with stitch claims
    @parties = ProductionParty.all
    if @sheet.prepared?
      @claim_map = claim_map(@sheet)          # design → { emb_id, ruined, contractor }
      @claim_colors_map = claim_colors_map(@sheet) # emb_id → { colours: [...], lines: [...] }
      @ruined_records = ruined_records(@sheet) # detailed ruined-suit records + billing effect
    end
  end

  # Record suits ruined (per design) → charges that contractor's khatta. Sets the exact
  # value (0 clears), and re-syncs this sheet's row targets. Same effect as the old stitching claim.
  def claim
    @sheet = ProductionSheet.find(params[:id])
    emb = KhattaEmb.find(params[:emb_id])
    lines = parse_claim_lines
    emb.replace_claim_colors!("stitch", lines)
    refresh_targets(@sheet)   # net-suit targets reflect the new stitch claim
    n = emb.reload.stitch_claim_suits.to_i
    msg = n.zero? ? "Cleared the claim for #{emb.contractor}." :
          "Claimed #{n} ruined suits across #{lines.size} colour#{'s' if lines.size != 1} against #{emb.contractor} — updated in Khatta (Billing)."
    redirect_to edit_production_sheet_path(@sheet), notice: msg
  end

  def create
    party = maybe_add_party
    @sheet = ProductionSheet.new(sheet_params); @sheet.save!
    redirect_to edit_production_sheet_path(@sheet), notice: notice_for(party)
  end

  def update
    party = maybe_add_party
    @sheet = ProductionSheet.find(params[:id])
    @sheet.update!(sheet_params)
    rebuild_earnings(@sheet)   # post each member's stitching earnings into their khata
    redirect_to edit_production_sheet_path(@sheet), notice: notice_for(party)
  end

  def destroy
    ProductionSheet.find(params[:id]).destroy
    redirect_to production_sheets_path, notice: "Sheet removed."
  end

  # Mark a sheet completed → route each design to Cutwork / Handmade progress based on its cost card.
  def complete
    sheet = ProductionSheet.find(params[:id])
    cards = CostCard.all.index_by(&:code)
    job_by_design = {}
    StitchingJob.includes(khatta_emb: :fabric_lot).where(start_on: sheet.stitch_date).each { |j| job_by_design[j.design.to_s] ||= j } if sheet.stitch_date
    sheet.production_progresses.delete_all
    made = { "cutwork" => 0, "handmade" => 0 }
    Array(sheet.rows).each_with_index do |design, i|
      suits = sheet.suits_for(i)
      next if suits <= 0
      c = cards[design.to_s]
      job = job_by_design[design.to_s]
      lot = job&.khatta_emb&.fabric_lot
      laat = job&.laat
      default_cw = CutworkParty.first_created&.id   # cutwork defaults to the first-created cutwork party
      %w[cutwork handmade].each do |stage|
        val = stage == "cutwork" ? c&.cut_work.to_f : c&.hand_made.to_f
        next unless val.positive?
        sheet.production_progresses.create!(design_code: design, laat: laat, suits: suits, stage: stage,
                                            fabric_lot_id: lot&.id,
                                            cutwork_party_id: (stage == "cutwork" ? default_cw : nil))
        made[stage] += 1
      end
    end
    sheet.update!(completed_at: Time.current)
    redirect_to production_sheets_path, notice: "✓ Completed — sent #{made['cutwork']} to Cutwork, #{made['handmade']} to Handmade progress."
  end

  def reopen
    sheet = ProductionSheet.find(params[:id])
    sheet.production_progresses.delete_all
    sheet.update!(completed_at: nil)
    redirect_to production_sheets_path, notice: "Reopened — moved back to Not Completed."
  end

  private

  # Post stitching earnings for each involved member: suits × the design's Shirt Stitch rate.
  # Recomputed from scratch on every save so edits stay in sync (no duplicates).
  def rebuild_earnings(sheet)
    return unless sheet.prepared?
    rates = StitchingCostCard.all.each_with_object({}) { |c, h| h[c.design_code] = c.shirt_stitch_rate.to_f }
    laat_by_design = {}
    StitchingJob.where(start_on: sheet.stitch_date).each { |j| laat_by_design[j.design.to_s] ||= j.laat } if sheet.stitch_date
    StitchingEarning.where(production_sheet_id: sheet.id).delete_all
    on = sheet.sheet_date || Date.current
    Array(sheet.rows).each_with_index do |design, i|
      rate  = rates[design.to_s].to_f
      cells = (sheet.values || {})[i.to_s] || {}
      cells.each do |pid, suits|
        s = suits.to_i
        next if s <= 0 || !ProductionParty.exists?(pid)
        StitchingEarning.create!(production_party_id: pid, production_sheet_id: sheet.id, design_code: design,
                                 laat: laat_by_design[design.to_s], suits: s, rate: rate,
                                 amount: (s * rate).round(2), earned_on: on)
      end
    end
  end

  # Recompute each row's target = current net suits (sent − ruined) for that design in the
  # stitch-date group, so a stitch claim made after preparing the sheet is reflected.
  def refresh_targets(sheet)
    return unless sheet.stitch_date
    net_by_design = Hash.new(0)
    StitchingJob.includes(:khatta_emb).where(start_on: sheet.stitch_date).each do |j|
      net_by_design[j.design.to_s] += (j.suits.to_i - j.khatta_emb&.stitch_claim_suits.to_i)
    end
    new_targets = Array(sheet.rows).map { |d| net_by_design[d.to_s] }
    sheet.update_column(:targets, new_targets) if new_targets != Array(sheet.targets)
  end

  # The ruined-suit records for this sheet (costing/payment live on the Khatta page).
  def ruined_records(sheet)
    return [] unless sheet.stitch_date
    StitchingJob.includes(:khatta_emb).where(start_on: sheet.stitch_date).filter_map do |j|
      emb = j.khatta_emb
      ruined = emb&.stitch_claim_suits.to_i
      next if ruined <= 0
      { laat: j.laat, design: j.design, contractor: emb.contractor.to_s, ruined: ruined, emb_id: emb.id }
    end
  end

  # For the colour grid in the stitch-claim modal: emb_id → { colours (id/name/net), existing lines }.
  def claim_colors_map(sheet)
    return {} unless sheet.stitch_date
    StitchingJob.includes(khatta_emb: { fabric_lot: [:fabric_lot_colors, { fabric_lot_lines: { design_variant: :design } }] })
                .where(start_on: sheet.stitch_date).each_with_object({}) do |j, h|
      emb = j.khatta_emb
      next unless emb && emb.fabric_lot && !h.key?(emb.id)
      cols  = emb.fabric_lot.color_suits_for(emb.design_code)
      lines = emb.claim_colors.select { |c| c.kind == "stitch" }.map { |c| { color_id: c.fabric_lot_color_id, suits: c.suits.to_i } }
      h[emb.id] = { colours: cols.map { |c| { id: c[:color_id], name: c[:name], net: c[:net] } }, lines: lines }
    end
  end

  # For the claim control: design → the dispatch (emb) to charge + its current ruined count.
  def claim_map(sheet)
    return {} unless sheet.stitch_date
    StitchingJob.includes(:khatta_emb).where(start_on: sheet.stitch_date).each_with_object({}) do |j, h|
      next if h[j.design.to_s] || j.khatta_emb_id.nil?
      h[j.design.to_s] = { emb_id: j.khatta_emb_id, ruined: j.khatta_emb&.stitch_claim_suits.to_i, contractor: j.khatta_emb&.contractor.to_s }
    end
  end

  # Adding a column creates a new production person (and their card).
  def maybe_add_party
    name = params[:new_party].to_s.strip
    return nil if name.blank?
    ProductionParty.find_or_create_by!(name: name)
  end

  def notice_for(party)
    party ? "Saved — added “#{party.name}” as a new production party." : "Production sheet saved."
  end

  def sheet_params
    ps   = params.require(:production_sheet)
    rows = ps[:rows];   rows = (JSON.parse(rows) rescue []) if rows.is_a?(String)
    vals = ps[:values]; vals = (JSON.parse(vals) rescue {}) if vals.is_a?(String)
    hid  = ps[:hidden_cols]; hid = (JSON.parse(hid) rescue []) if hid.is_a?(String)
    out  = { sheet_date: ps[:sheet_date], day: ps[:day], rows: Array(rows), values: (vals || {}), hidden_cols: Array(hid).map(&:to_s) }
    # prepared sheets keep their fixed design rows & targets — don't let the form overwrite them
    if @sheet&.prepared?
      out[:rows] = @sheet.rows      # designs are fixed/uneditable
    end
    out
  end
  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Production Sheet." unless current_user.can_see?("production_sheet")
  end
  def block_view_only
    redirect_to production_sheets_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
