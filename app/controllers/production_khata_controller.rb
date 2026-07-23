class ProductionKhataController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[add_payment remove_payment]

  # Per production party: earnings (we owe for stitching) − payments = balance.
  def index
    parties = ProductionParty.includes(:stitching_earnings, :stitching_payments, :production_claims)
                             .select { |p| p.stitching_earnings.any? || p.stitching_payments.any? || p.production_claims.any? }
    @ledgers = parties.map do |p|
      entries = []
      p.stitching_earnings.each do |e|
        entries << { date: e.earned_on, detail: "Stitching — #{e.suits} × #{e.design_code}#{" · Laat ##{e.laat}" if e.laat}",
                     earn: e.amount.to_f, paid: 0, kind: "earn" }
      end
      p.stitching_payments.each do |pay|
        entries << { date: pay.paid_on, detail: (pay.method_detail.presence || "Payment") + (pay.notes.present? ? " · #{pay.notes}" : ""),
                     earn: 0, paid: pay.amount.to_f, kind: "payment", id: pay.id, payment: pay }
      end
      p.production_claims.each do |cl|
        cols = Array(cl.colors).map { |h| "#{(h["suits"] || h[:suits])} #{h["name"] || h[:name]}" }.join(", ")
        entries << { date: cl.claimed_on, detail: "⚠ Claim — #{cl.suits} ruined suits · #{cl.design_code}#{" · Laat ##{cl.laat}" if cl.laat}#{" (#{cols})" if cols.present?}",
                     earn: 0, paid: cl.amount.to_f, kind: "claim" }
      end
      entries.sort_by! { |e| [e[:date] || Date.new(1900, 1, 1), e[:kind] == "earn" ? 0 : 1] }
      bal = 0.0
      entries.each { |e| bal += e[:earn] - e[:paid]; e[:balance] = bal.round(2) }
      { party: p, entries: entries, earned: p.earned, paid: p.paid, balance: p.balance }
    end.sort_by { |l| -l[:balance] }

    @tot_earned  = @ledgers.sum { |l| l[:earned] }
    @tot_paid    = @ledgers.sum { |l| l[:paid] }
    @tot_balance = @ledgers.sum { |l| l[:balance] }
    @parties     = @ledgers.map { |l| l[:party].name }.sort
  end

  def add_payment
    pay = StitchingPayment.new(production_party_id: params[:production_party_id], amount: params[:amount],
                               paid_on: params[:paid_on].presence || Date.current,
                               method_detail: params[:method_detail], notes: params[:notes])
    pay.proof.attach(params[:proof]) if params[:proof].present?
    pay.save!
    redirect_to(params[:return_to].presence || production_khata_path, notice: "Payment recorded.")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to(params[:return_to].presence || production_khata_path, alert: e.record.errors.full_messages.to_sentence)
  end

  def remove_payment
    StitchingPayment.find(params[:id]).destroy
    redirect_to production_khata_path, notice: "Payment removed."
  end

  private
  def require_section
    redirect_to dashboard_path, alert: "You don't have access to the Detail Ledger." unless current_user.can_see?("prod_khata")
  end
  def block_view_only
    redirect_to production_khata_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
