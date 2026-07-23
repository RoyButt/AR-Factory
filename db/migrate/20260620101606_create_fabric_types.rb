class CreateFabricTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :fabric_types do |t|
      t.string :name
      t.integer :year
      t.decimal :rate, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
