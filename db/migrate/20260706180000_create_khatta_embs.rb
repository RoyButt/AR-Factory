class CreateKhattaEmbs < ActiveRecord::Migration[7.0]
  def change
    create_table :khatta_embs do |t|
      t.string :contractor          # embroidery party
      t.string :design_code         # links to the cost card (for EMB cost)
      t.integer :suits, default: 0  # suits returned from embroidery
      t.date :returned_on
      t.string :notes
      t.timestamps
    end
  end
end
