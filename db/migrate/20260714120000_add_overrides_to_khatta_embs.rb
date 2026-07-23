class AddOverridesToKhattaEmbs < ActiveRecord::Migration[7.0]
  def change
    add_column :khatta_embs, :bill_override,  :decimal, precision: 12, scale: 2
    add_column :khatta_embs, :claim_override, :decimal, precision: 12, scale: 2
  end
end
