class AddPreparedToProductionSheets < ActiveRecord::Migration[7.0]
  def change
    add_column :production_sheets, :prepared, :boolean, default: false
    add_column :production_sheets, :targets, :json
    add_column :production_sheets, :stitch_date, :date
  end
end
