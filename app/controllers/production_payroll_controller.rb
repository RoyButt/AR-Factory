class ProductionPayrollController < ApplicationController
  before_action :require_login
  before_action :require_section

  # Weekly view (Mon–Sun): one compact row per worker for the selected week.
  def index
    base = (Date.parse(params[:week]) rescue Date.current)
    @week_start = base.beginning_of_week(:monday)
    @week_end   = @week_start + 6
    @prev_week  = (@week_start - 7).to_s
    @next_week  = (@week_start + 7).to_s
    @is_current = @week_start == Date.current.beginning_of_week(:monday)

    # weeks that actually have activity (for the picker)
    dates = (StitchingEarning.pluck(:earned_on) + StitchingPayment.pluck(:paid_on)).compact
    @weeks = dates.map { |d| d.beginning_of_week(:monday) }.uniq.sort.reverse

    parties = ProductionParty.includes(:stitching_earnings, :stitching_payments).all
    @rows = parties.map do |p|
      wk_earn = p.stitching_earnings.select { |e| in_week?(e.earned_on) }.sum { |e| e.amount.to_f }.round(2)
      wk_paid = p.stitching_payments.select { |pay| in_week?(pay.paid_on) }.sum { |pay| pay.amount.to_f }.round(2)
      suits   = p.stitching_earnings.select { |e| in_week?(e.earned_on) }.sum { |e| e.suits.to_i }
      { party: p, suits: suits, wk_earned: wk_earn, wk_paid: wk_paid,
        wk_balance: (wk_earn - wk_paid).round(2), outstanding: p.balance }
    end.select { |r| r[:wk_earned] > 0 || r[:wk_paid] > 0 || r[:outstanding] != 0 }
       .sort_by { |r| [-(r[:wk_balance]), -r[:outstanding]] }

    @tot_earned      = @rows.sum { |r| r[:wk_earned] }
    @tot_paid        = @rows.sum { |r| r[:wk_paid] }
    @tot_outstanding = @rows.sum { |r| r[:outstanding] }
    @unpaid_count    = @rows.count { |r| r[:wk_balance] > 0 }
  end

  private

  def in_week?(d) = d && d >= @week_start && d <= @week_end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Weekly Pay." unless current_user.can_see?("prod_payroll")
  end
end
