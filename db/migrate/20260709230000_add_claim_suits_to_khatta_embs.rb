class AddClaimSuitsToKhattaEmbs < ActiveRecord::Migration[7.0]
  def change
    add_column :khatta_embs, :claim_suits, :integer, default: 0
  end
end
