class CreateClaimColors < ActiveRecord::Migration[7.0]
  def change
    create_table :claim_colors do |t|
      t.bigint  :khatta_emb_id
      t.string  :kind                 # "emb" (damaged at embroidery) or "stitch" (ruined at stitching)
      t.bigint  :fabric_lot_color_id
      t.string  :color_name
      t.integer :suits, default: 0, null: false
      t.timestamps
    end
    add_index :claim_colors, :khatta_emb_id
    add_index :claim_colors, [:khatta_emb_id, :kind]
  end
end
