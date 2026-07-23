class CreateLotAdjustments < ActiveRecord::Migration[7.0]
  def change
    create_table :lot_adjustments do |t|
      t.references :fabric_lot, null: false, foreign_key: true
      t.references :fabric_lot_color, foreign_key: true
      t.string  :contractor
      t.string  :design
      t.decimal :gazana, precision: 10, scale: 2, default: 0
      t.text    :note
      t.timestamps
    end
  end
end
