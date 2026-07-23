class CreateCostCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cost_cards do |t|
      t.string  :code
      t.decimal :fabric_rate,       precision: 10, scale: 2, default: 0
      t.decimal :fabric_multiplier, precision: 6,  scale: 2, default: 4
      t.decimal :cmt,               precision: 10, scale: 2, default: 0
      t.decimal :cut_work,          precision: 10, scale: 2, default: 0
      t.decimal :hand_made,         precision: 10, scale: 2, default: 0
      t.decimal :cm,                precision: 10, scale: 2, default: 0
      t.decimal :lass,              precision: 10, scale: 2, default: 0
      t.date    :card_date

      t.timestamps
    end
  end
end
