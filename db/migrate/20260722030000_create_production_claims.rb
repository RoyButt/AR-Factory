class CreateProductionClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :production_claims do |t|
      t.bigint  :production_progress_id
      t.bigint  :handmade_pass_id
      t.bigint  :production_party_id
      t.string  :design_code
      t.integer :laat
      t.decimal :rate,   precision: 12, scale: 2, default: 0   # cost card final rate at claim time
      t.integer :suits,  default: 0
      t.decimal :amount, precision: 12, scale: 2, default: 0   # suits × rate — deducted from the person
      t.json    :colors                                        # [{ color_id, name, suits }]
      t.date    :claimed_on
      t.timestamps
    end
    add_index :production_claims, :production_progress_id
    add_index :production_claims, :production_party_id
  end
end
