class KhattaDelivery < ApplicationRecord
  belongs_to :khatta_emb
  default_scope { order(:delivered_on, :id) }

  # A return batch is "allowed" once it's been accepted into stock.
  def allowed?
    allowed_at.present?
  end
end
