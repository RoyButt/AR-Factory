class CreatePartyPrices < ActiveRecord::Migration[7.0]
  def change
    create_table :party_prices do |t|
      t.references :cost_card, null: false, foreign_key: true
      t.string  :party_name
      t.string  :pricing_mode, default: "markup_pct"
      t.decimal :value, precision: 10, scale: 2, default: 0
      t.string  :note

      t.timestamps
    end
  end
end
