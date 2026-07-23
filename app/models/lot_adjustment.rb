class LotAdjustment < ApplicationRecord
  belongs_to :fabric_lot
  belongs_to :fabric_lot_color, optional: true

  # Reserved contractor: the owner's direct employee. When charged, it's the owner's own loss.
  MASTER = "Master".freeze
  scope :master, -> { where(contractor: MASTER) }

  # Extra meters issued to a contractor (e.g. re-work after cloth was ruined).
  # Subtracted from that colour's Remaining Gazana on the lot sheet.
end
