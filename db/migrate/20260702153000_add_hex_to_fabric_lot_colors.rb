class AddHexToFabricLotColors < ActiveRecord::Migration[7.0]
  def change
    add_column :fabric_lot_colors, :hex, :string
  end
end
