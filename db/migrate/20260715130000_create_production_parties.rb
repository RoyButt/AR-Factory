class CreateProductionParties < ActiveRecord::Migration[7.0]
  def change
    create_table :production_parties do |t|
      t.string :name, null: false
      t.string :contact
      t.text   :notes
      t.integer :position
      t.timestamps
    end
  end
end
