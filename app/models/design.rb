class Design < ApplicationRecord
  has_many :design_variants, dependent: :destroy
  has_one_attached :picture
  accepts_nested_attributes_for :design_variants, allow_destroy: true,
    reject_if: ->(a) { a["size"].blank? && a["repeats_per_color"].to_f.zero? }

  validates :code, presence: true

  # Category is derived from the code (no manual field).
  before_validation { self.category = code.to_s.end_with?("-P") ? "Printed" : "Embroidered" }

  # The finalized cost card for this design (linked by code).
  def cost_card
    @cost_card ||= CostCard.find_by(code: code)
  end

  # Image shown for the design = the cost card's product image.
  def display_picture
    cc = cost_card
    cc&.picture&.attached? ? cc.picture : (picture.attached? ? picture : nil)
  end

  # Average per-piece consumption across variants (links to Settings via the variants).
  def avg_per_piece
    vs = design_variants.reject { |v| v.heads.zero? }
    return 0 if vs.empty?
    (vs.sum(&:per_piece_avg) / vs.size).round(2)
  end
end
