class AddEmbroideryToProductionLots < ActiveRecord::Migration[7.0]
  def change
    add_column :production_lots, :emb_sent_date, :date
    add_column :production_lots, :emb_sent_qty, :integer
    add_column :production_lots, :emb_received_date, :date
    add_column :production_lots, :emb_received_qty, :integer
    add_column :production_lots, :emb_paid, :boolean, default: false, null: false
    add_column :production_lots, :emb_paid_date, :date
  end
end
