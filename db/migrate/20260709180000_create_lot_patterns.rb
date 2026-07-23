class CreateLotPatterns < ActiveRecord::Migration[7.0]
  def change
    create_table :lot_patterns do |t|
      t.references :fabric_lot, null: false, foreign_key: true
      t.string  :name
      t.json    :data
      t.boolean :finalized, default: false, null: false
      t.timestamps
    end
  end
end
