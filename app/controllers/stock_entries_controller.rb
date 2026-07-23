class StockEntriesController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[create update destroy send_for_stitching cancel_stitching]

  # In Stock shows ONE row per fully-returned dispatch (contractor + design + laat),
  # not per return batch — multiple batches are summed into a single row.
  def index
    start_by_emb = StitchingJob.where.not(khatta_emb_id: nil).pluck(:khatta_emb_id, :start_on).to_h
    rows = KhattaEmb.includes(:khatta_deliveries, fabric_lot: :fabric_lot_colors)
                    .where.not(fabric_lot_id: nil).filter_map do |emb|
      next if emb.contractor.blank?
      next unless emb.suits_sent.to_i.positive? && emb.returned >= emb.suits_sent.to_i   # fully returned only
      lot = emb.fabric_lot
      { date: emb.khatta_deliveries.map(&:delivered_on).compact.max,
        source: emb.contractor.to_s, product: (emb.design_code.presence || "Embroidered suits"),
        qty: [emb.returned - emb.stitch_claim_suits.to_i, 0].max, unit: "suits", laat: lot&.laat_number, lot_id: lot&.id,
        colours: (lot ? lot.fabric_lot_colors.map { |c| { name: c.name, hex: c.swatch } } : []),
        emb_id: emb.id, sent: start_by_emb.key?(emb.id), start_on: start_by_emb[emb.id] }
    end

    @rows     = rows.sort_by { |r| r[:date] || Date.new(1900, 1, 1) }.reverse
    @sources  = @rows.map { |r| r[:source] }.reject(&:blank?).uniq.sort
    @products = @rows.map { |r| r[:product] }.reject(&:blank?).uniq.sort
    @laats    = @rows.map { |r| r[:laat] }.compact.uniq
    @months   = @rows.map { |r| r[:date]&.strftime("%B %Y") }.compact.uniq
  end

  # Send a fully-returned dispatch (all its suits) to the Supervisor for stitching, with a start date.
  def send_for_stitching
    emb = KhattaEmb.find(params[:emb_id])
    unless emb.suits_sent.to_i.positive? && emb.returned >= emb.suits_sent.to_i
      return redirect_to stock_entries_path, alert: "Can't send yet — not all suits for this laat/design have been returned."
    end
    if StitchingJob.exists?(khatta_emb_id: emb.id)
      return redirect_to stock_entries_path, alert: "Already sent for stitching."
    end
    StitchingJob.create!(khatta_emb: emb, supervisor: "Supervisor", suits: emb.returned,
                         design: emb.design_code, laat: emb.fabric_lot&.laat_number,
                         sent_on: Date.current, start_on: params[:start_on].presence || Date.current)
    redirect_to stock_entries_path, notice: "Sent to Supervisor for stitching — start #{params[:start_on]}."
  end

  # Revert a send — removes the stitching job so the dispatch is back in stock, ready to re-send.
  def cancel_stitching
    emb = KhattaEmb.find(params[:emb_id])
    StitchingJob.where(khatta_emb_id: emb.id).destroy_all
    redirect_to stock_entries_path, notice: "Cancelled — Laat ##{emb.fabric_lot&.laat_number} (#{emb.design_code}) is back in stock."
  end

  def create
    @entry = StockEntry.new(entry_params)
    if @entry.save
      redirect_to stock_entries_path, notice: "Stock entry added — #{@entry.product_name}."
    else
      redirect_to stock_entries_path, alert: @entry.errors.full_messages.to_sentence
    end
  end

  def update
    StockEntry.find(params[:id]).update(entry_params)
    redirect_to stock_entries_path, notice: "Stock entry updated."
  end

  def destroy
    StockEntry.find(params[:id]).destroy
    redirect_to stock_entries_path, notice: "Stock entry removed."
  end

  private

  def entry_params
    params.require(:stock_entry).permit(:stock_date, :source, :product_name, :quantity, :unit, :notes)
  end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to In Stock." unless current_user.can_see?("instock")
  end

  def block_view_only
    redirect_to stock_entries_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
