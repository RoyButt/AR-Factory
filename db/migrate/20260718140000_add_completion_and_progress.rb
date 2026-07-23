class AddCompletionAndProgress < ActiveRecord::Migration[7.0]
  def change
    add_column :production_sheets, :completed_at, :datetime
    create_table :production_progresses do |t|
      t.references :production_sheet, foreign_key: true
      t.references :fabric_lot, foreign_key: true
      t.string  :design_code
      t.integer :laat
      t.integer :suits
      t.string  :stage   # "cutwork" | "handmade"
      t.timestamps
    end
  end
end
