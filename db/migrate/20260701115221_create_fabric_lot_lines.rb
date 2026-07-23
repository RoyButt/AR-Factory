class CreateFabricLotLines < ActiveRecord::Migration[7.0]
  def change
    create_table :fabric_lot_lines do |t|
      t.references :fabric_lot, null: false, foreign_key: true
      t.references :fabric_lot_color, null: true, foreign_key: true
      t.references :design_variant, null: true, foreign_key: true
      t.string  :contractor
      t.integer :suits, default: 0

      t.timestamps
    end
  end
end
