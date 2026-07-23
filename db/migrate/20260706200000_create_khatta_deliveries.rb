class CreateKhattaDeliveries < ActiveRecord::Migration[7.0]
  def change
    create_table :khatta_deliveries do |t|
      t.references :khatta_emb, null: false, foreign_key: true
      t.integer :suits, default: 0
      t.date :delivered_on
      t.timestamps
    end
  end
end
