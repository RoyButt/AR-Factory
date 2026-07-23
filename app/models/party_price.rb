class PartyPrice < ApplicationRecord
  belongs_to :cost_card

  MODES = {
    "markup_pct"    => "Markup %",
    "markup_amount" => "+/- Amount",
    "fixed"         => "Fixed price"
  }.freeze

  # Party-specific final rate, derived from the card's base final rate.
  def final_price(base)
    base = base.to_f
    case pricing_mode
    when "markup_pct"    then (base * (1 + value.to_f / 100.0)).round
    when "markup_amount" then (base + value.to_f).round
    when "fixed"         then value.to_f.round
    else base.round
    end
  end

  def diff(base)
    final_price(base) - base.to_f.round
  end

  def mode_label
    MODES[pricing_mode] || pricing_mode
  end
end
