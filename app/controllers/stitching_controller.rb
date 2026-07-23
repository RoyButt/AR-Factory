class StitchingController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[prepare_sheet]

  def index
    @jobs = StitchingJob.includes(khatta_emb: { fabric_lot: [:fabric_lot_colors, { fabric_lot_lines: { design_variant: :design } }] }).all
    # one box per start date, earliest start first
    @by_date = @jobs.group_by { |j| j.start_on }
                    .sort_by { |date, _| date || Date.new(1900, 1, 1) }
    # Back Up cloth breakdown per batch (pulled from each laat's fabric lot), for the "See backup" modal.
    @backup_by_date = {}
    @by_date.each do |date, jobs|
      sections = jobs.map { |j| backup_section(j) }.compact
      @backup_by_date[date] = { sections: sections, total: sections.sum { |s| s[:subtotal] }.round(2) }
    end
  end

  # Prepare ONE production sheet for a whole date group — one row per stitching job,
  # design auto-filled (uneditable), each row's target = its net suits.
  def prepare_sheet
    date = (Date.parse(params[:date]) rescue nil)
    jobs = StitchingJob.includes(:khatta_emb).where(start_on: date).order(:id)
    sheet = ProductionSheet.find_or_initialize_by(stitch_date: date)
    if sheet.new_record?
      sheet.assign_attributes(
        sheet_date: Date.current, day: Date.current.strftime("%A"), prepared: true,
        rows:    jobs.map { |j| j.design.to_s },
        targets: jobs.map { |j| j.suits.to_i - j.khatta_emb&.stitch_claim_suits.to_i },
        values:  {},
        hidden_cols: ProductionSheet.last_hidden_cols   # inherit off/unavailable persons from the last sheet
      )
      sheet.save!
    end
    redirect_to edit_production_sheet_path(sheet)
  end

  private

  # One backup breakdown for a single stitching job: laat + design + per-colour (suits, Back Up),
  # read straight from that laat's fabric lot lines so it matches the fabric-lots matrix.
  def backup_section(job)
    emb = job.khatta_emb
    lot = emb&.fabric_lot
    return nil unless lot
    code  = emb.design_code.to_s
    lines = lot.fabric_lot_lines.select do |l|
      l.contractor.to_s == emb.contractor.to_s && l.design_variant && l.design_variant.design.code.to_s == code
    end
    return nil if lines.empty?
    colours = lot.fabric_lot_colors.filter_map do |c|
      used = lines.select { |l| l.backup_factor_for(c.id) > 0 }
      next if used.empty?
      { name: c.name, hex: c.swatch,
        suits:  used.sum { |l| l.heads },
        backup: used.sum { |l| l.backup_for(c.id) }.round(2) }
    end
    return nil if colours.empty?
    { laat: job.laat.presence || lot.laat_number, design: job.design.presence || code,
      contractor: emb.contractor, colours: colours,
      subtotal: colours.sum { |c| c[:backup] }.round(2) }
  end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Stitching." unless current_user.can_see?("stitching")
  end
  def block_view_only
    redirect_to stitching_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
