class AddHeadSizeToFabricLotLines < ActiveRecord::Migration[7.0]
  def change
    add_column :fabric_lot_lines, :head_size, :integer
  end
end
