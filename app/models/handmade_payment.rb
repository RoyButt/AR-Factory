class HandmadePayment < ApplicationRecord
  belongs_to :handmade_party, optional: true
  has_one_attached :proof
  validates :amount, numericality: { greater_than: 0 }
  default_scope { order(paid_on: :desc, id: :desc) }
end
