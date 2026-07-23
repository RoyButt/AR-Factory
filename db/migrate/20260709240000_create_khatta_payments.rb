class CreateKhattaPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :khatta_payments do |t|
      t.string  :contractor, null: false
      t.decimal :amount, precision: 12, scale: 2, default: 0
      t.date    :paid_on
      t.string  :method_detail
      t.text    :notes
      t.timestamps
    end
    add_index :khatta_payments, :contractor
  end
end
