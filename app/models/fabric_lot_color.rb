class FabricLotColor < ApplicationRecord
  belongs_to :fabric_lot
  has_many :fabric_lot_lines, dependent: :nullify
  has_many :line_color_usages, dependent: :destroy
  has_many :lot_adjustments, dependent: :destroy

  # Fixed fabric-colour palette (name => swatch hex). Drives the dropdown and
  # the row highlight. Extendable in Settings later.
  PALETTE = {
    "Zinic"   => "#9AA7AF",
    "Gajari"  => "#E8743B",
    "Black"   => "#2B2F33",
    "Red"     => "#C0392B",
    "Pista"   => "#8FBF6F",
    "Due"     => "#6C8EBF",
    "White"   => "#EDEFF2",
    "Cream"   => "#EFE4C8",
    "Navy"    => "#2C3E60",
    "Maroon"  => "#7B241C",
    "Green"   => "#278B4F",
    "Blue"    => "#2E6BC0",
    "Sky"     => "#7FC4E6",
    "Grey"    => "#8894A2",
    "Brown"   => "#8B5E3C",
    "Mustard" => "#D4A017",
    "Purple"  => "#7D5BA6",
    "Pink"    => "#E38AA9"
  }.freeze

  # Swatch colour for the chip / row tint: stored hex, else palette lookup, else neutral.
  def swatch
    hex.presence || PALETTE[name] || "#cbd5e1"
  end

  # Each line consumes this colour by its per-colour EMB + Back Up usage
  # (which may be full, half or 0, overriding the design's computed value).
  def consumed
    fabric_lot.fabric_lot_lines.sum { |l| l.emb_for(id) + l.backup_for(id) }.round(2)
  end

  # Extra meters manually issued to a contractor for this colour (re-work / ruined cloth).
  def adjustments_total
    lot_adjustments.sum { |a| a.gazana.to_f }.round(2)
  end

  # Remaining gaz = received − consumed − wastage − extra cloth issued (adjustments).
  def remaining
    (received_gazana.to_f - consumed - wastage.to_f - adjustments_total).round(2)
  end

  def gaz_per_suit
    Setting.value_for("gaz_per_suit_issued", 3.5)
  end

  # Total Suits this colour's cloth can yield = received ÷ 3.5.
  def total_suits
    gaz_per_suit.zero? ? 0 : (received_gazana.to_f / gaz_per_suit).round
  end

  # Used Suits = consumed gazana (Σ EMB+Backup of assigned designs) ÷ 3.5.
  def used_suits
    gaz_per_suit.zero? ? 0 : (consumed / gaz_per_suit).round
  end

  # Remaining suits = remaining gazana ÷ 3.5 (Total − Used reconciles).
  def remaining_suits
    gaz_per_suit.zero? ? 0 : (remaining / gaz_per_suit).round
  end
end
