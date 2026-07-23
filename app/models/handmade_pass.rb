class HandmadePass < ApplicationRecord
  belongs_to :handmade_party, optional: true
  belongs_to :production_progress, optional: true
  default_scope { order(created_at: :desc, id: :desc) }
  def effective_rate; (rate.to_f + adjustment.to_f).round(2); end
  def amount;         (suits.to_i * effective_rate).round(2); end
  def token;          "HP-#{id.to_s.rjust(5, '0')}"; end
  def colours;        production_progress&.colours || (production_progress&.fabric_lot ? production_progress.fabric_lot.fabric_lot_colors.map { |c| { name: c.name, hex: c.swatch } } : []); end
  def color_suits;    production_progress&.color_suits || (production_progress&.fabric_lot ? production_progress.fabric_lot.color_suits_for(design_code) : []); end
end
