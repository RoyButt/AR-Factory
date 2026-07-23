class CreateLineColorUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :line_color_usages do |t|
      t.references :fabric_lot_line, null: false, foreign_key: true
      t.references :fabric_lot_color, null: false, foreign_key: true
      t.decimal :emb, precision: 10, scale: 2
      t.decimal :backup, precision: 10, scale: 2
      t.timestamps
    end
  end
end
