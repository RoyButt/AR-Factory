class StitchingEarning < ApplicationRecord
  belongs_to :production_party
  belongs_to :production_sheet, optional: true
end
