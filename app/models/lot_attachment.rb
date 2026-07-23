class LotAttachment < ApplicationRecord
  belongs_to :production_lot
  has_one_attached :file

  validates :stage, presence: true
end
