class AddSuitsSentToKhattaEmbs < ActiveRecord::Migration[7.0]
  def change
    add_column :khatta_embs, :suits_sent, :integer, default: 0
  end
end
