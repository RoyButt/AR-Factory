class StitchingPayment < ApplicationRecord
  belongs_to :production_party
  has_one_attached :proof
  validates :amount, numericality: { greater_than: 0 }
end
