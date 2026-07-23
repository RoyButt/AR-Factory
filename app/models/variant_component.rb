class VariantComponent < ApplicationRecord
  belongs_to :design_variant
  validates :name, presence: true
  validates :value, presence: true
end
