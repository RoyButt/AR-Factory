class SettingsController < ApplicationController
  before_action :require_login
  before_action :block_view_only

  # Bulk update of formula constants.
  def update
    (params[:settings] || {}).each do |id, attrs|
      Setting.where(id: id).first&.update(value: attrs[:value])
    end
    Setting.reset_cache!
    redirect_to master_data_path(tab: "settings"), notice: "Settings saved."
  end

  private

  def block_view_only
    redirect_to master_data_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
