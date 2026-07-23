class CreateLotAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :lot_attachments do |t|
      t.references :production_lot, null: false, foreign_key: true
      t.string :stage
      t.string :note

      t.timestamps
    end
  end
end
