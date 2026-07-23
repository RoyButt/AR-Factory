class FabricLotsController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[new create edit update destroy apply_pattern finalize_pattern remove_pattern]
  before_action :set_lot, only: %i[show edit update destroy apply_pattern finalize_pattern remove_pattern]
  before_action :variant_options, only: %i[new create edit update show]

  def index
    @lots = FabricLot.includes(:lot_patterns, { fabric_lot_colors: :lot_adjustments }, fabric_lot_lines: { design_variant: :design }).order(created_at: :desc)
  end

  def show; end

  def new
    @lot = FabricLot.new(line_type: "6Line", lot_date: Date.current)
    %w[Zinic Gajari Black Red Pista Due].each do |c|
      @lot.fabric_lot_colors.build(name: c, hex: FabricLotColor::PALETTE[c])
    end
  end

  def create
    @lot = FabricLot.new(lot_params)
    if @lot.save
      redirect_to fabric_lot_path(@lot), notice: "Fabric lot created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  # Printable Gate Pass (A5 / half-A4). Two parts:
  #  • Gazana detail — per selected contractor: EMB cloth per colour + horizontal total + sign space.
  #  • Embroidery program — per head, each design with its line count ("laat count").
  # No contractors param = all contractors on the lot.
  def gate_pass
    @lot = FabricLot.find(params[:id])
    @colours = @lot.fabric_lot_colors.to_a
    names = Array(params[:contractors]).reject(&:blank?)
    lines = @lot.fabric_lot_lines.select { |l| l.contractor.present? && l.design_variant }
    lines = lines.select { |l| names.include?(l.contractor) } if names.any?

    @gaze = lines.group_by(&:contractor).map do |contractor, ls|
      per_colour = @colours.map { |c| ls.sum { |l| l.emb_for(c.id) }.round(2) }
      { contractor: contractor, per_colour: per_colour, total: per_colour.sum.round(2) }
    end
    # Embroidery program rows, first column = machine head. Complete laats (every colour Full)
    # are aggregated per head as "N laat complete"; partial laats list their per-colour suits.
    @program = []
    lines.group_by { |l| l.design_variant.design.code }.sort_by { |code, _| code.to_s }.each do |code, dls|
      complete = dls.select { |l| @colours.all? { |c| l.factor_for(c.id) == 1.0 } }
      complete.group_by(&:heads).sort.each do |head, hls|
        # every colour full → head suits per colour, across all colours, for each complete laat
        suits = hls.size * head * @colours.size
        @program << { head: head, design: code, complete: hls.size, colours: nil, suits: suits }
      end
      (dls - complete).each do |l|
        cols = @colours.filter_map { |c| f = l.factor_for(c.id); next if f <= 0; { name: c.name, hex: c.swatch, suits: (l.heads * f).round } }
        @program << { head: l.heads, design: code, complete: nil, colours: cols, suits: cols.sum { |c| c[:suits] } }
      end
    end
    render layout: "print"
  end

  def update
    if @lot.update(lot_params)
      case params[:add]
      when "colour"
        @lot.fabric_lot_colors.create(name: "New Colour", hex: "#cbd5e1", received_gazana: 0, wastage: 0)
        return redirect_to fabric_lot_path(@lot), notice: "Colour added — name it and enter Received Gazana."
      when "line"
        @lot.fabric_lot_lines.create(contractor: "")
        return redirect_to fabric_lot_path(@lot), notice: "Design line added — pick a contractor, design & head."
      end
      if params[:save_pattern_name].present?
        name = params[:save_pattern_name].to_s.strip
        @lot.lot_patterns.create(name: name.presence || "Pattern #{@lot.lot_patterns.count + 1}", data: @lot.reload.snapshot)
        return redirect_to fabric_lot_path(@lot), notice: "Saved pattern “#{name}”. Keep going, then finalize one."
      end
      redirect_to fabric_lot_path(@lot), notice: "Fabric lot updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Load a saved pattern back into the live sheet (replaces current colours/lines).
  def apply_pattern
    pat = @lot.lot_patterns.find(params[:pattern_id])
    @lot.apply_snapshot!(pat.data)
    redirect_to fabric_lot_path(@lot), notice: "Loaded pattern “#{pat.name}” into the sheet."
  end

  # Mark one pattern as the finalized/official one (clears the Draft warning).
  def finalize_pattern
    pat = @lot.lot_patterns.find(params[:pattern_id])
    @lot.lot_patterns.update_all(finalized: false)
    pat.update!(finalized: true)
    redirect_to fabric_lot_path(@lot), notice: "Finalized “#{pat.name}”. This is now the official sheet."
  end

  def remove_pattern
    @lot.lot_patterns.find(params[:pattern_id]).destroy
    redirect_to fabric_lot_path(@lot), notice: "Pattern removed."
  end

  def destroy
    @lot.destroy
    redirect_to fabric_lots_path, notice: "Fabric lot removed."
  end

  private

  def set_lot
    @lot = FabricLot.includes(:lot_patterns, { lot_adjustments: :fabric_lot_color },
                              { fabric_lot_colors: :lot_adjustments },
                              fabric_lot_lines: [:line_color_usages, { design_variant: :design }]).find(params[:id])
  end

  def variant_options
    variants = DesignVariant.includes(:design, :variant_components).order("designs.code")
    @variant_options = variants.map do |v|
      ["#{v.design.code}#{" (#{v.size})" if v.size.present?}", v.id]
    end
    # id => { per-suit consumption, EMB & Backup consumption } from Designs (AR),
    # so the edit form can show them and subtract suits live
    @variant_calc = variants.each_with_object({}) do |v, h|
      h[v.id] = { pp: v.per_piece_avg, emb: v.emb_consumption, backup: v.backup_consumption }
    end
    # Recipe per design code (representative variant + its repeats & components) so EMB / Back Up
    # can be computed by formula for ANY machine head, even a head with no exact variant.
    @design_recipe = {}
    variants.each do |v|
      @design_recipe[v.design.code] ||= {
        variant_id: v.id, repeats: v.repeats_per_color.to_f, components: v.components_sum
      }
    end
    @design_codes = @design_recipe.keys.sort
    @head_sizes = variants.map { |v| v.size.to_s }.reject(&:blank?).uniq.sort_by(&:to_i)
    @emb_factor = Setting.value_for("emb_factor", 0.337).to_f
    @round_step = Setting.value_for("rounding_step", 0.5).to_f
    @backup_div = Setting.value_for("backup_divisor", 39).to_f
    @emb_parties = EmbParty.pluck(:name)   # Contractor dropdown = embroidery parties
  end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Fabric Lots." unless current_user.can_see?("fabric")
  end

  def block_view_only
    redirect_to fabric_lots_path, alert: "View-only users cannot edit." if current_user.view_only?
  end


  def lot_params
    params.require(:fabric_lot).permit(
      :laat_number, :line_type, :lot_date, :total_suit, :notes,
      fabric_lot_colors_attributes: %i[id name hex received_gazana wastage _destroy],
      lot_adjustments_attributes: %i[id fabric_lot_color_id contractor design gazana note date _destroy],
      fabric_lot_lines_attributes: [:id, :contractor, :design_variant_id, :head_size, :fabric_lot_color_id, :suits, :_destroy,
        { line_color_usages_attributes: %i[id fabric_lot_color_id factor backup_factor _destroy] }]
    )
  end
end
