class CreateProductionSheets < ActiveRecord::Migration[7.0]
  def change
    create_table :production_sheets do |t|
      t.date :sheet_date
      t.string :day
      t.json :rows      # ["AR-1","AR-2",...]  design codes
      t.json :values    # {"rowIndex":{"partyId":qty}}
      t.timestamps
    end
  end
end
