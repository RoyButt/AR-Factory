class KhattaPayment < ApplicationRecord
  has_one_attached :proof
  validates :contractor, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
