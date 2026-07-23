class EmbParty < ApplicationRecord
  has_one_attached :image
  validates :name, presence: true
  default_scope { order(:name) }
end
