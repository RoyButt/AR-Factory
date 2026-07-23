class CreateFabricLotColors < ActiveRecord::Migration[7.0]
  def change
    create_table :fabric_lot_colors do |t|
      t.references :fabric_lot, null: false, foreign_key: true
      t.string  :name
      t.decimal :received_gazana, precision: 10, scale: 2, default: 0
      t.decimal :wastage,         precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
