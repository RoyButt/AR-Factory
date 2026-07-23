class AddFamilyContactToProductionParties < ActiveRecord::Migration[7.0]
  def change
    add_column :production_parties, :family_contact, :string
  end
end
