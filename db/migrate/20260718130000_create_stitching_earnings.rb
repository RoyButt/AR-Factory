class CreateStitchingEarnings < ActiveRecord::Migration[7.0]
  def change
    create_table :stitching_earnings do |t|
      t.references :production_party, foreign_key: true
      t.references :production_sheet, foreign_key: true
      t.string  :design_code
      t.integer :laat
      t.integer :suits
      t.decimal :rate,   precision: 10, scale: 2
      t.decimal :amount, precision: 12, scale: 2
      t.date    :earned_on
      t.timestamps
    end
  end
end
