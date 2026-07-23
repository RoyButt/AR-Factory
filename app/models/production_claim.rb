class ProductionClaim < ApplicationRecord
  belongs_to :production_progress, optional: true
  belongs_to :handmade_pass, optional: true
  belongs_to :production_party, optional: true
  default_scope { order(created_at: :desc, id: :desc) }
end
