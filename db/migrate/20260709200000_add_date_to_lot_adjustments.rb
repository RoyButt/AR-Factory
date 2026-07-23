class AddDateToLotAdjustments < ActiveRecord::Migration[7.0]
  def change
    add_column :lot_adjustments, :date, :date
  end
end
