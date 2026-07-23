class CreateCardAddons < ActiveRecord::Migration[7.0]
  def change
    create_table :card_addons do |t|
      t.references :cost_card, null: false, foreign_key: true
      t.string  :target, default: "final"
      t.string  :label
      t.decimal :amount, precision: 10, scale: 2, default: 0

      t.timestamps
    end
  end
end
