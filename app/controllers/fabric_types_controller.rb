class FabricTypesController < ApplicationController
  before_action :require_login
  before_action :block_view_only

  def create
    FabricType.create(fabric_params)
    redirect_to master_data_path(tab: "fabric"), notice: "Fabric type added."
  end

  def update
    FabricType.find(params[:id]).update(fabric_params)
    redirect_to master_data_path(tab: "fabric"), notice: "Fabric type updated."
  end

  def destroy
    FabricType.find(params[:id]).destroy
    redirect_to master_data_path(tab: "fabric"), notice: "Fabric type removed."
  end

  private

  def block_view_only
    redirect_to master_data_path, alert: "View-only users cannot edit." if current_user.view_only?
  end

  def fabric_params
    params.require(:fabric_type).permit(:name, :year, :rate)
  end
end
