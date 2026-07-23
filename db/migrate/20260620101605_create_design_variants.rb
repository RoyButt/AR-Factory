class CreateDesignVariants < ActiveRecord::Migration[7.0]
  def change
    create_table :design_variants do |t|
      t.references :design, null: false, foreign_key: true
      t.string :size
      t.decimal :repeats_per_color, precision: 8, scale: 2, default: 0
      t.decimal :trousers, precision: 8, scale: 2, default: 0
      t.decimal :back,     precision: 8, scale: 2, default: 0
      t.decimal :bazoo,    precision: 8, scale: 2, default: 0
      t.decimal :kali,     precision: 8, scale: 2, default: 0
      t.decimal :falas,    precision: 8, scale: 2, default: 0

      t.timestamps
    end
  end
end
