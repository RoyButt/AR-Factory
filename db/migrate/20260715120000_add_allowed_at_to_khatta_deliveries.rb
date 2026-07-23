class AddAllowedAtToKhattaDeliveries < ActiveRecord::Migration[7.0]
  def change
    add_column :khatta_deliveries, :allowed_at, :datetime
  end
end
