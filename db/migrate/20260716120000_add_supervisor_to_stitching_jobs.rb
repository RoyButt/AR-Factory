class AddSupervisorToStitchingJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :stitching_jobs, :supervisor, :string, default: "Supervisor"
    add_column :stitching_jobs, :start_on, :date
  end
end
