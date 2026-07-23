class CreateVariantComponents < ActiveRecord::Migration[7.0]
  def change
    create_table :variant_components do |t|
      t.references :design_variant, null: false, foreign_key: true
      t.string  :name
      t.decimal :value, precision: 8, scale: 2, default: 0
      t.timestamps
    end
  end
end
