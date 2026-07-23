class EmbMasterController < ApplicationController
  before_action :require_login
  before_action :require_section

  # Master = owner's direct employee. Every extra-cloth charge on "Master" is the owner's loss.
  def index
    @rate_for = CostCard.all.each_with_object({}) { |c, h| h[c.code] = c.fabric_rate.to_f }
    @rows = LotAdjustment.master.includes(:fabric_lot, :fabric_lot_color)
                         .sort_by { |a| [a.date || Date.new(1900, 1, 1), a.id] }.reverse
    @total_meters = @rows.sum { |a| a.gazana.to_f }.round(2)
    @total_cost   = @rows.sum { |a| a.gazana.to_f * @rate_for[a.design].to_f }.round(2)
    @laats    = @rows.map { |a| a.fabric_lot&.laat_number }.compact.uniq
    @articles = @rows.map(&:design).compact.reject(&:blank?).uniq.sort
    @months   = @rows.map { |a| a.date&.strftime("%B %Y") }.compact.uniq
  end

  private

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Emb Master." unless current_user.can_see?("emb_master")
  end
end
