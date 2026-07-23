class StitchingJob < ApplicationRecord
  belongs_to :khatta_delivery, optional: true
  belongs_to :khatta_emb, optional: true
  belongs_to :production_party, optional: true
  default_scope { order(sent_on: :desc, id: :desc) }
end
