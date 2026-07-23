class FabricLotLine < ApplicationRecord
  belongs_to :fabric_lot
  belongs_to :fabric_lot_color, optional: true
  belongs_to :design_variant, optional: true
  has_many :line_color_usages, dependent: :destroy
  accepts_nested_attributes_for :line_color_usages, allow_destroy: true

  # Per-colour usage factor for this line: 1 = full (calculated), 0.5 = half, 0 = none.
  def usage_for(color_id)
    line_color_usages.detect { |u| u.fabric_lot_color_id == color_id }
  end

  def factor_for(color_id)          # EMB cell factor
    u = usage_for(color_id)
    u && !u.factor.nil? ? u.factor.to_f : 1.0
  end

  def backup_factor_for(color_id)   # Back Up cell factor (independent)
    u = usage_for(color_id)
    u && !u.backup_factor.nil? ? u.backup_factor.to_f : 1.0
  end

  def emb_for(color_id)
    (emb_consumption * factor_for(color_id)).round(2)
  end

  def backup_for(color_id)
    (backup_consumption * backup_factor_for(color_id)).round(2)
  end

  # Machine head for this line — the chosen head, else the design variant's own size.
  def heads
    (head_size.presence || design_variant&.size).to_s[/\d+/].to_i
  end

  # EMB / Back Up computed from the design's recipe (repeats + components) at the chosen head,
  # so any machine head gives a value even if that exact variant doesn't exist.
  def emb_consumption
    return 0 unless design_variant
    ceil_to(Setting.value_for("emb_factor", 0.337) * heads * design_variant.repeats_per_color.to_f)
  end

  def backup_consumption
    return 0 unless design_variant
    div = Setting.value_for("backup_divisor", 39)
    div.zero? ? 0 : ceil_to((design_variant.components_sum / div) * heads)
  end

  # Gazana used by assigning this design = EMB + Back Up Consumption.
  def gazana_used
    (emb_consumption + backup_consumption).round(2)
  end

  def per_piece
    heads.zero? ? 0 : ((emb_consumption + backup_consumption) / heads).round(3)
  end

  def design_label
    return "—" unless design_variant
    "#{design_variant.design.code}#{" (#{heads})" if heads.positive?}"
  end

  private

  def ceil_to(value)
    step = Setting.value_for("rounding_step", 0.5)
    return value if step.to_f.zero?
    ((value / step).round(9)).ceil * step
  end
end
