class CreateDesigns < ActiveRecord::Migration[7.0]
  def change
    create_table :designs do |t|
      t.string :code
      t.string :category
      t.text :notes

      t.timestamps
    end
  end
end
