class CreateFabricLots < ActiveRecord::Migration[7.0]
  def change
    create_table :fabric_lots do |t|
      t.string :laat_number
      t.string :line_type
      t.date :lot_date
      t.integer :total_suit
      t.string :notes

      t.timestamps
    end
  end
end
