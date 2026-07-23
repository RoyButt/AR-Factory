class FabricLot < ApplicationRecord
  has_many :fabric_lot_colors, dependent: :destroy
  has_many :fabric_lot_lines, dependent: :destroy
  has_many :lot_patterns, -> { order(:created_at) }, dependent: :destroy
  has_many :lot_adjustments, dependent: :destroy
  has_many :khatta_embs, dependent: :nullify

  # [contractor, design_code] pairs whose Khatta (Emb) dispatch is FULLY returned (complete).
  # Only these lock — a contractor part-returning does NOT freeze anything.
  def completed_dispatch_pairs
    @completed_dispatch_pairs ||= khatta_embs.includes(:khatta_deliveries).select do |e|
      e.suits_sent.to_i.positive? && e.returned >= e.suits_sent.to_i
    end.map { |e| [e.contractor.to_s, e.design_code.to_s] }
  end

  # A single design line is locked only when its contractor's whole dispatch has been returned.
  def line_locked?(line)
    return false unless line.contractor.present? && line.design_variant
    completed_dispatch_pairs.include?([line.contractor.to_s, line.design_variant.design.code.to_s])
  end
  accepts_nested_attributes_for :fabric_lot_colors, allow_destroy: true,
    reject_if: ->(a) { a["name"].blank? }
  accepts_nested_attributes_for :fabric_lot_lines, allow_destroy: true,
    reject_if: ->(a) { a["design_variant_id"].blank? }
  accepts_nested_attributes_for :lot_adjustments, allow_destroy: true,
    reject_if: ->(a) { a["gazana"].blank? || a["fabric_lot_color_id"].blank? }

  validates :laat_number, presence: true

  # ---- draft / finalize (saved patterns) ----
  def finalized_pattern
    lot_patterns.detect(&:finalized?)
  end

  def finalized?
    finalized_pattern.present?
  end

  # Serialize the current sheet into a self-contained snapshot (colours by position).
  def snapshot
    cols = fabric_lot_colors.order(:id).to_a
    idx  = cols.each_with_index.to_h { |c, i| [c.id, i] }
    {
      "line_type" => line_type,
      "colours" => cols.map do |c|
        { "name" => c.name, "hex" => c.hex, "received_gazana" => c.received_gazana.to_f, "wastage" => c.wastage.to_f }
      end,
      "lines" => fabric_lot_lines.order(:id).map do |l|
        {
          "contractor" => l.contractor,
          "design_variant_id" => l.design_variant_id,
          "head_size" => l.head_size,
          "suits" => l.suits,
          "usages" => l.line_color_usages.map do |u|
            { "c" => idx[u.fabric_lot_color_id], "factor" => u.factor.to_f, "backup_factor" => u.backup_factor.to_f }
          end.select { |u| u["c"] }
        }
      end
    }
  end

  # Rebuild the sheet's colours + lines + factors from a saved snapshot.
  def apply_snapshot!(data)
    data = (data || {})
    transaction do
      fabric_lot_lines.destroy_all
      fabric_lot_colors.destroy_all
      new_cols = Array(data["colours"]).map do |c|
        fabric_lot_colors.create!(name: c["name"], hex: c["hex"],
                                  received_gazana: c["received_gazana"], wastage: c["wastage"])
      end
      Array(data["lines"]).each do |l|
        line = fabric_lot_lines.create!(contractor: l["contractor"], design_variant_id: l["design_variant_id"],
                                        head_size: l["head_size"], suits: l["suits"])
        Array(l["usages"]).each do |u|
          col = new_cols[u["c"].to_i]
          next unless col
          line.line_color_usages.create!(fabric_lot_color_id: col.id,
                                         factor: u["factor"], backup_factor: u["backup_factor"])
        end
      end
    end
  end

  def title
    [line_type.presence, ("Laat ##{laat_number}" if laat_number.present?)].compact.join(" · ")
  end

  # Suits per colour for a design = Σ over that design's lines of (machine head × colour factor:
  # Full=1, Half=0.5, 0=none). e.g. head 24 · Zinic Full = 24; head 32 · Black Half = 16.
  # Returns [{ color_id, name, hex, base, claimed, net }] for colours actually used (base > 0).
  def color_suits_for(design_code)
    lines = fabric_lot_lines.select { |l| l.design_variant && l.design_variant.design.code.to_s == design_code.to_s }
    claimed = claimed_color_suits(design_code)
    fabric_lot_colors.filter_map do |c|
      base = lines.sum { |l| l.heads * l.factor_for(c.id) }.round
      next if base <= 0
      cl = claimed[c.id].to_i
      { color_id: c.id, name: c.name, hex: c.swatch, base: base, claimed: cl, net: [base - cl, 0].max }
    end
  end

  # Suits claimed per fabric_lot_color_id (both emb + stitch claims) for a design in this lot.
  def claimed_color_suits(design_code)
    embs = khatta_embs.select { |e| e.design_code.to_s == design_code.to_s }
    embs.flat_map(&:claim_colors).group_by(&:fabric_lot_color_id)
        .transform_values { |cs| cs.sum { |c| c.suits.to_i } }
  end

  # ---- totals ----
  def total_received
    fabric_lot_colors.sum { |c| c.received_gazana.to_f }.round(2)
  end

  def total_consumed
    fabric_lot_colors.sum(&:consumed).round(2)
  end

  def total_remaining
    fabric_lot_colors.sum(&:remaining).round(2)
  end

  # Total Suits = total received gaz ÷ gaz per suit issued (3.5) — the cloth's suit capacity.
  def total_suits
    div = Setting.value_for("gaz_per_suit_issued", 3.5)
    div.zero? ? 0 : (total_received / div).round
  end

  # Used Suits = consumed gazana (Σ EMB+Backup of assigned designs) ÷ 3.5.
  def used_suits
    div = Setting.value_for("gaz_per_suit_issued", 3.5)
    div.zero? ? 0 : (total_consumed / div).round
  end
  alias_method :suits_cut, :used_suits

  # Remaining Suits = remaining gaz ÷ 3.5 (so Total − Used = Remaining reconciles).
  def remaining_suits
    div = Setting.value_for("gaz_per_suit_issued", 3.5)
    div.zero? ? 0 : (total_remaining / div).round
  end
  alias_method :remain_suit, :remaining_suits
end
