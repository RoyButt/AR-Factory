class StitchingCostCardsController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[create destroy]

  def index
    @cards = StitchingCostCard.order(:design_code)
    have   = @cards.map(&:design_code)
    # dropdown lists ONLY designs whose stitching cost card isn't created yet
    @designs = Design.order(:code).reject { |d| have.include?(d.code) }
    @total_designs = Design.count
    @missing_count = @designs.size
    if params[:design].present?
      @design = Design.find_by(code: params[:design])
      @card   = StitchingCostCard.find_or_initialize_by(design_code: params[:design])
      @detail = design_detail(@design) if @design
    end
  end

  def create
    code = params[:design_code].to_s
    card = StitchingCostCard.find_or_initialize_by(design_code: code)
    card.update!(shirt_stitch_rate: params[:shirt_stitch_rate], trouser_stitch_rate: params[:trouser_stitch_rate],
                 shirt_overlock: params[:shirt_overlock])
    redirect_to stitching_cost_cards_path, notice: "Stitching card saved for #{code}."
  end

  def destroy
    card = StitchingCostCard.find(params[:id])
    code = card.design_code
    card.destroy
    redirect_to stitching_cost_cards_path, notice: "Removed stitching card for #{code}."
  end

  private

  def design_detail(design)
    lots = FabricLot.joins(fabric_lot_lines: :design_variant)
                    .where(design_variants: { design_id: design.id }).distinct
    colours = FabricLotColor.where(fabric_lot_id: lots.select(:id))
                            .map { |c| { name: c.name, hex: c.swatch } }.uniq { |h| h[:name] }
    variant = design.design_variants.first
    { laats: lots.map(&:laat_number).compact.uniq, colours: colours,
      picture: design.display_picture, category: design.category,
      head_sizes: design.design_variants.map(&:size).reject(&:blank?).uniq }
  end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Stitching Cost Card." unless current_user.can_see?("stitch_cost")
  end

  def block_view_only
    redirect_to stitching_cost_cards_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
