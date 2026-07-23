class ProductionSheet < ApplicationRecord
  has_many :production_progresses, dependent: :destroy
  default_scope { order(sheet_date: :desc, id: :desc) }

  def completed?; completed_at.present?; end

  # The hidden-column set of the most recently created sheet — a new sheet inherits it so
  # off/unavailable persons stay removed without re-hiding them every time. Copied by value,
  # so editing a sheet's columns never affects any other sheet.
  def self.last_hidden_cols
    reorder(created_at: :desc, id: :desc).limit(1).pick(:hidden_cols) || []
  end

  # Suits distributed for a given design row index (sum across all members).
  def suits_for(row_index)
    ((values || {})[row_index.to_s] || {}).values.sum { |v| v.to_i }
  end
end
