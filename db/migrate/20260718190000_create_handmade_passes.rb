class CreateHandmadePasses < ActiveRecord::Migration[7.0]
  def change
    create_table :handmade_passes do |t|
      t.references :handmade_party, foreign_key: true
      t.references :production_progress, foreign_key: true
      t.string  :design_code
      t.integer :laat
      t.integer :suits
      t.decimal :rate,       precision: 10, scale: 2, default: 0
      t.decimal :adjustment, precision: 10, scale: 2, default: 0
      t.date    :pass_on
      t.text    :notes
      t.timestamps
    end
    create_table :handmade_payments do |t|
      t.references :handmade_party, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2
      t.date    :paid_on
      t.string  :method_detail
      t.text    :notes
      t.timestamps
    end
  end
end
