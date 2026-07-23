class CreateCutworkParties < ActiveRecord::Migration[7.0]
  def change
    create_table :cutwork_parties do |t|
      t.string :name
      t.string :contact
      t.string :email
      t.string :address
      t.string :city
      t.text   :notes
      t.timestamps
    end
  end
end
