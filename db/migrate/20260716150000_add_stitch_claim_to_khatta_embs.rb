class AddStitchClaimToKhattaEmbs < ActiveRecord::Migration[7.0]
  def change
    add_column :khatta_embs, :stitch_claim_suits, :integer, default: 0
  end
end
