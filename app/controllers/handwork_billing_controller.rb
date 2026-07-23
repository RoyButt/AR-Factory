class HandworkBillingController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[add_payment remove_payment]

  # Handwork cost = Σ (suits × (Handmade rate from cost card + adjustment)) per generated pass.
  def index
    @rows = HandmadePass.includes(:handmade_party, production_progress: :fabric_lot).map do |p|
      { id: p.id, pass: p.token, date: p.pass_on, party: p.handmade_party&.name, party_id: p.handmade_party_id,
        laat: p.laat, design: p.design_code, suits: p.suits.to_i, rate: p.rate.to_f, adjustment: p.adjustment.to_f,
        eff: p.effective_rate, amount: p.amount, colours: p.colours }
    end.sort_by { |r| [-(r[:date]&.to_time&.to_i || 0), r[:design].to_s] }

    @total_handwork = @rows.sum { |r| r[:amount] }.round(2)
    @total_suits    = @rows.sum { |r| r[:suits] }
    @payments       = HandmadePayment.includes(:handmade_party).all
    @total_paid     = @payments.sum { |p| p.amount.to_f }.round(2)
    @remaining      = (@total_handwork - @total_paid).round(2)
    @parties        = HandmadeParty.all
    @default_hm_id  = HandmadeParty.reorder(:id).first&.id

    paid_by   = @payments.group_by(&:handmade_party_id).transform_values { |ps| ps.sum { |p| p.amount.to_f } }
    earned_by = @rows.group_by { |r| r[:party_id] }.transform_values { |rs| rs.sum { |r| r[:amount] } }
    ids = (earned_by.keys + paid_by.keys).uniq
    @by_party = ids.map do |pid|
      name = pid ? (HandmadeParty.find_by(id: pid)&.name || "—") : "Unassigned"
      e = (earned_by[pid] || 0).round(2); pd = (paid_by[pid] || 0).round(2)
      { name: name, earned: e, paid: pd, remaining: (e - pd).round(2) }
    end.sort_by { |h| -h[:remaining] }
  end

  def add_payment
    editing = params[:payment_id].present?
    pay = editing ? HandmadePayment.find(params[:payment_id]) : HandmadePayment.new
    pay.assign_attributes(handmade_party_id: params[:handmade_party_id].presence, amount: params[:amount],
                          paid_on: params[:paid_on].presence || (pay.paid_on || Date.current),
                          method_detail: params[:method_detail], notes: params[:notes])
    pay.proof.attach(params[:proof]) if params[:proof].present?
    pay.save!
    redirect_to handwork_billing_path, notice: editing ? "Payment updated." : "Handwork payment recorded."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to handwork_billing_path, alert: e.record.errors.full_messages.to_sentence
  end

  def remove_payment
    HandmadePayment.find(params[:id]).destroy
    redirect_to handwork_billing_path, notice: "Payment removed."
  end

  private
  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Handwork Billing." unless current_user.can_see?("handwork_bill")
  end
  def block_view_only
    redirect_to handwork_billing_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
