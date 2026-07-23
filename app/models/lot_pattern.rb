class LotPattern < ApplicationRecord
  belongs_to :fabric_lot

  # data = self-contained snapshot of the sheet (colours + lines + Full/Half/0 factors),
  # colours referenced by position so it can be re-applied after ids change.
end
