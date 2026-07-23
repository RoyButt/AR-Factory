class AddFabricLotToKhattaEmbs < ActiveRecord::Migration[7.0]
  def change
    add_reference :khatta_embs, :fabric_lot, foreign_key: true
  end
end
