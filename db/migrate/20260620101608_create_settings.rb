class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :label
      t.decimal :value, precision: 12, scale: 4, default: 0
      t.string :grouping

      t.timestamps
    end
    add_index :settings, :key, unique: true
  end
end
