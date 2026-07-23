class AddCutworkPartyToProgress < ActiveRecord::Migration[7.0]
  def change
    add_reference :production_progresses, :cutwork_party, foreign_key: true
  end
end
