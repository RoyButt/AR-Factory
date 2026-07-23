class DesignVariant < ApplicationRecord
  belongs_to :design
  has_many :variant_components, dependent: :destroy
  accepts_nested_attributes_for :variant_components, allow_destroy: true,
    reject_if: ->(a) { a["name"].blank? && a["value"].to_f.zero? }

  # Every field must be filled (0.0 is an acceptable value).
  validates :size, presence: true
  validates :repeats_per_color, :trousers, :bazoo, :kali, :falas, presence: true

  # Machine heads = the numeric size token (e.g. "28" -> 28). Printed variants -> 0.
  def heads
    size.to_s[/\d+/].to_i
  end

  # Sum of the fixed components + any extra components added by the user.
  def components_sum
    [trousers, back, bazoo, kali, falas].compact.sum.to_f +
      variant_components.sum { |c| c.value.to_f }
  end

  # EMB Consumption = CEILING(emb_factor * heads * repeats, rounding_step)
  def emb_consumption
    step = Setting.value_for("rounding_step", 0.5)
    ceil_to(Setting.value_for("emb_factor", 0.337) * heads * repeats_per_color.to_f, step)
  end

  # Back Up Consumption = CEILING((sum(components)/backup_divisor) * heads, rounding_step)
  def backup_consumption
    step = Setting.value_for("rounding_step", 0.5)
    div = Setting.value_for("backup_divisor", 39)
    div.zero? ? 0 : ceil_to((components_sum / div) * heads, step)
  end

  # Per-Piece Average = (EMB + Backup) / heads
  def per_piece_avg
    return 0 if heads.zero?
    ((emb_consumption + backup_consumption) / heads).round(3)
  end

  private

  def ceil_to(value, step)
    return value if step.to_f.zero?
    # round away float noise (e.g. 84.0000001) before ceiling, matching Excel CEILING
    ((value / step).round(9)).ceil * step
  end
end
