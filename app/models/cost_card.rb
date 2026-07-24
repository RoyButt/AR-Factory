class CostCard < ApplicationRecord
  has_one_attached :picture
  has_many :emb_files, dependent: :destroy
  has_many :cost_lines, dependent: :destroy
  has_many :card_addons, dependent: :destroy
  has_many :party_prices, dependent: :destroy
  accepts_nested_attributes_for :card_addons, allow_destroy: true,
    reject_if: ->(a) { a["label"].blank? && a["amount"].to_f.zero? }
  accepts_nested_attributes_for :emb_files, allow_destroy: true,
    reject_if: ->(a) { a["file_name"].blank? && a["stitch"].to_f.zero? }
  accepts_nested_attributes_for :cost_lines, allow_destroy: true,
    reject_if: ->(a) { a["name"].blank? }
  accepts_nested_attributes_for :party_prices, allow_destroy: true,
    reject_if: ->(a) { a["party_name"].blank? }

  validates :code, presence: true, uniqueness: { case_sensitive: false, message: "already exists" }

  # EMB Rate table: sum of file line totals (sheet K10)
  def emb_subtotal
    emb_files.sum(&:line_total)
  end

  def emb_addons
    card_addons.select { |a| a.target == "emb" }
  end

  def final_addons
    card_addons.select { |a| a.target == "final" }
  end

  # Price Calc — EMB Cost line (sheet C4 = K10 + EMB add-ons)
  def emb_cost
    emb_subtotal + emb_addons.sum { |a| a.amount.to_f }
  end

  # Fabric line (sheet C3 = fabric_rate * fabric_multiplier)
  def fabric_cost
    fabric_rate.to_f * fabric_multiplier.to_f
  end

  # Sum of user-added custom lines (after Lass)
  def extra_total
    cost_lines.sum { |l| l.amount.to_f }
  end

  # Total (sheet C10 = SUM of all price-calc lines)
  def total
    fabric_cost + emb_cost + cmt.to_f + cut_work.to_f + hand_made.to_f + cm.to_f + lass.to_f + extra_total
  end

  # Final Rate (sheet D10 = Total + Final add-ons)
  def final_rate
    total + final_addons.sum { |a| a.amount.to_f }
  end

  # The price-calculation line items (for the left panel), matching the sheet order.
  def price_lines
    [
      ["Fabric",    fabric_cost],
      ["EMB Cost",  emb_cost],
      ["CMT",       cmt.to_f],
      ["Cut work",  cut_work.to_f],
      ["Hand Made", hand_made.to_f],
      ["CM",        cm.to_f],
      ["Lass",      lass.to_f]
    ] + cost_lines.map { |l| [l.name, l.amount.to_f] }
  end
end
