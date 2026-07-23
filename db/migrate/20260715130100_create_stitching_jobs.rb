class CreateStitchingJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :stitching_jobs do |t|
      t.references :khatta_delivery, foreign_key: true
      t.references :production_party, foreign_key: true
      t.integer :suits
      t.string  :design
      t.integer :laat
      t.date    :sent_on
      t.text    :notes
      t.timestamps
    end
  end
end
