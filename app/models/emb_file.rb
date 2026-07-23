class EmbFile < ApplicationRecord
  belongs_to :cost_card

  # Sheet K: = ROUND( (stitch / stitch_divisor) * rate * heads , 0 ) * reapts
  def line_total
    div = Setting.value_for("stitch_divisor", 1000)
    return 0 if div.zero?
    ((stitch.to_f / div) * rate.to_f * heads.to_f).round(0) * reapts.to_f
  end
end
