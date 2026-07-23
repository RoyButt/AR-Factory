class AddHiddenColsToProductionSheets < ActiveRecord::Migration[7.0]
  def change
    add_column :production_sheets, :hidden_cols, :json
  end
end
