class AddHandmadeRateToHandmadeParties < ActiveRecord::Migration[7.0]
  def change
    add_column :handmade_parties, :handmade_rate, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
