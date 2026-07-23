class WorkersController < ApplicationController
  before_action :require_login
  before_action :block_view_only

  def create
    Worker.create(worker_params)
    redirect_to master_data_path(tab: "workers"), notice: "Worker added."
  end

  def update
    Worker.find(params[:id]).update(worker_params)
    redirect_to master_data_path(tab: "workers"), notice: "Worker updated."
  end

  def destroy
    Worker.find(params[:id]).destroy
    redirect_to master_data_path(tab: "workers"), notice: "Worker removed."
  end

  private

  def block_view_only
    redirect_to master_data_path, alert: "View-only users cannot edit." if current_user.view_only?
  end

  def worker_params
    params.require(:worker).permit(:name, :piece_rate, :active)
  end
end
