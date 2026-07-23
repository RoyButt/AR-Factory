class AddAddonsToCostCards < ActiveRecord::Migration[7.0]
  def change
    add_column :cost_cards, :emb_addon,   :decimal, precision: 10, scale: 2, default: 25
    add_column :cost_cards, :final_addon, :decimal, precision: 10, scale: 2, default: 100
  end
end
