class CreateProductionLots < ActiveRecord::Migration[7.0]
  def change
    create_table :production_lots do |t|
      t.string :emb_name
      t.string :design
      t.string :laat_number
      t.integer :total_suit
      t.date :production_date
      t.date :cutwork_sent_date
      t.boolean :cutwork_paid, default: false, null: false
      t.date :cutwork_paid_date
      t.date :overlock_sent_date
      t.boolean :overlock_paid, default: false, null: false
      t.date :overlock_paid_date
      t.boolean :handmade_paid, default: false, null: false
      t.date :handmade_paid_date
      t.date :handmade_return_date
      t.date :press_date
      t.date :out_date

      t.timestamps
    end
  end
end
