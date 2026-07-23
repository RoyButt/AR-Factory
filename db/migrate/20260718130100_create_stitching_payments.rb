class CreateStitchingPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :stitching_payments do |t|
      t.references :production_party, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2
      t.date    :paid_on
      t.string  :method_detail
      t.text    :notes
      t.timestamps
    end
  end
end
