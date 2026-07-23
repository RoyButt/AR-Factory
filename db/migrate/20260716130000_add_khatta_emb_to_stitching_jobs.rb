class AddKhattaEmbToStitchingJobs < ActiveRecord::Migration[7.0]
  def change
    add_reference :stitching_jobs, :khatta_emb, foreign_key: true
  end
end
