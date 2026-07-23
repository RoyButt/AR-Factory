class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    redirect_to login_path, alert: "Please sign in to continue." unless logged_in?
  end

  # Parse the repeatable colour+suits grid from a claim modal into clean line hashes.
  # Accepts params[:claim_colors] as an array (or hash) of { color_id, suits }.
  def parse_claim_lines
    raw = params[:claim_colors]
    return [] if raw.blank?
    arr = raw.respond_to?(:values) ? raw.values : raw
    arr.filter_map do |ln|
      cid   = ln[:color_id].to_i
      suits = ln[:suits].to_i
      next if cid <= 0 || suits <= 0
      { color_id: cid, color_name: FabricLotColor.find_by(id: cid)&.name, suits: suits }
    end
  end
end
