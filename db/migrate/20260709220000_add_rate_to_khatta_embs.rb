class AddRateToKhattaEmbs < ActiveRecord::Migration[7.0]
  def change
    add_column :khatta_embs, :rate, :decimal, precision: 10, scale: 2
  end
end
