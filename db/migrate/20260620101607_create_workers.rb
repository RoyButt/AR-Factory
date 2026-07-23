class CreateWorkers < ActiveRecord::Migration[7.0]
  def change
    create_table :workers do |t|
      t.string :name
      t.decimal :piece_rate, precision: 8, scale: 2, default: 0
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
