class CreateStockEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_entries do |t|
      t.date    :stock_date
      t.string  :source          # "In Stock From"
      t.string  :product_name
      t.decimal :quantity, precision: 12, scale: 2, default: 0
      t.string  :unit
      t.text    :notes
      t.timestamps
    end
  end
end
