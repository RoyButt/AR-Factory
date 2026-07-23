class ClaimColor < ApplicationRecord
  belongs_to :khatta_emb, optional: true
  belongs_to :fabric_lot_color, optional: true
  validates :suits, numericality: { greater_than: 0 }
end
