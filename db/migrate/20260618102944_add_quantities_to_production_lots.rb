class AddQuantitiesToProductionLots < ActiveRecord::Migration[7.0]
  def change
    add_column :production_lots, :cutwork_sent_qty, :integer
    add_column :production_lots, :cutwork_received_qty, :integer
    add_column :production_lots, :overlock_sent_qty, :integer
    add_column :production_lots, :overlock_received_qty, :integer
    add_column :production_lots, :handmade_sent_qty, :integer
    add_column :production_lots, :handmade_received_qty, :integer
  end
end
