class ProductionProgress < ApplicationRecord
  belongs_to :production_sheet, optional: true
  belongs_to :fabric_lot, optional: true
  belongs_to :cutwork_party, optional: true
  has_one :handmade_pass, dependent: :nullify
  has_many :production_claims, dependent: :destroy
  default_scope { order(created_at: :desc, id: :desc) }

  def colours
    fabric_lot ? fabric_lot.fabric_lot_colors.map { |c| { name: c.name, hex: c.swatch } } : []
  end

  # Suits per colour for this item's design (head × factor), minus suits claimed for each colour
  # (both the embroidery/stitch colour-claims on the lot AND handmade-step production claims here).
  # [{ color_id, name, hex, base, claimed, net }]
  def color_suits
    base = fabric_lot ? fabric_lot.color_suits_for(design_code) : []
    extra = production_claims.flat_map { |c| Array(c.colors) }.each_with_object(Hash.new(0)) do |h, acc|
      acc[(h["color_id"] || h[:color_id]).to_i] += (h["suits"] || h[:suits]).to_i
    end
    base.map do |c|
      more = extra[c[:color_id].to_i]
      c.merge(claimed: c[:claimed] + more, net: [c[:base] - c[:claimed] - more, 0].max)
    end
  end
  def net_suits; color_suits.sum { |c| c[:net] }; end
  def final_rate; CostCard.find_by(code: design_code)&.final_rate.to_f; end

  # Cutwork rate = the design's cost-card Cutwork price + this row's adjustment (+/−).
  # Adjustment defaults to 0, so it never changes existing rows unless set.
  def cutwork_base_rate; CostCard.find_by(code: design_code)&.cut_work.to_f; end
  def effective_cutwork_rate; (cutwork_base_rate + adjustment.to_f).round(2); end
  def cutwork_amount; (suits.to_i * effective_cutwork_rate).round(2); end
end
