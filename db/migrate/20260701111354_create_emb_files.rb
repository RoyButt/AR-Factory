class CreateEmbFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :emb_files do |t|
      t.references :cost_card, null: false, foreign_key: true
      t.integer :sr
      t.string  :file_name
      t.integer :stitch,  default: 0
      t.decimal :heads,   precision: 6, scale: 2, default: 0
      t.decimal :reapts,  precision: 6, scale: 2, default: 1
      t.decimal :rate,    precision: 6, scale: 3, default: 0

      t.timestamps
    end
  end
end
