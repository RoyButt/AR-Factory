class StitchingCostCard < ApplicationRecord
  validates :design_code, presence: true, uniqueness: true

  def design; @design ||= Design.find_by(code: design_code); end
  def total_rate; (shirt_stitch_rate.to_f + trouser_stitch_rate.to_f + shirt_overlock.to_f).round(2); end
end
