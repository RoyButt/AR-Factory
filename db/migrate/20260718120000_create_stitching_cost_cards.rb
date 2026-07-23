class CreateStitchingCostCards < ActiveRecord::Migration[7.0]
  def change
    create_table :stitching_cost_cards do |t|
      t.string  :design_code, null: false
      t.decimal :shirt_stitch_rate,   precision: 10, scale: 2, default: 0
      t.decimal :trouser_stitch_rate, precision: 10, scale: 2, default: 0
      t.decimal :shirt_overlock,      precision: 10, scale: 2, default: 0
      t.timestamps
    end
    add_index :stitching_cost_cards, :design_code, unique: true
  end
end
