class CutworkParty < ApplicationRecord
  has_one_attached :image
  validates :name, presence: true
  default_scope { order(:name) }

  # The first-created party (used as the default assignee), ignoring the alphabetical scope.
  def self.first_created; reorder(:id).first; end
end
