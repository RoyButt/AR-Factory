class ProductionLotsController < ApplicationController
  before_action :require_login
  before_action :block_view_only, only: %i[new create edit update destroy]
  before_action :set_lot, only: %i[edit update destroy]

  def new
    @lot = ProductionLot.new
  end

  def create
    @lot = ProductionLot.new(lot_params)
    if @lot.save
      process_attachments(@lot)
      redirect_to dashboard_path(anchor: "lot-#{@lot.id}"), notice: "Production lot added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @lot.update(lot_params)
      process_attachments(@lot)
      redirect_to dashboard_path(anchor: "lot-#{@lot.id}"), notice: "Lot updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lot.destroy
    redirect_to dashboard_path, notice: "Lot removed."
  end

  private

  def set_lot
    @lot = ProductionLot.find(params[:id])
  end

  def block_view_only
    redirect_to dashboard_path, alert: "View-only users cannot edit." if current_user.view_only?
  end

  # Create new attachments (per stage) and remove any flagged for deletion.
  def process_attachments(lot)
    Array(params[:remove_attachment_ids]).reject(&:blank?).each do |id|
      lot.lot_attachments.where(id: id).destroy_all
    end

    (params[:attachments] || {}).each do |stage, files|
      next unless ProductionLot::STAGES.include?(stage.to_s)
      Array(files).reject(&:blank?).each do |file|
        lot.lot_attachments.create(stage: stage.to_s, file: file)
      end
    end
  end

  def lot_params
    params.require(:production_lot).permit(
      :emb_name, :design, :laat_number, :total_suit, :production_date,
      :emb_sent_date, :emb_sent_qty, :emb_received_date, :emb_received_qty, :emb_paid, :emb_paid_date,
      :cutwork_sent_date, :cutwork_sent_qty, :cutwork_received_qty, :cutwork_paid, :cutwork_paid_date,
      :overlock_sent_date, :overlock_sent_qty, :overlock_received_qty, :overlock_paid, :overlock_paid_date,
      :handmade_sent_qty, :handmade_received_qty, :handmade_paid, :handmade_paid_date, :handmade_return_date,
      :press_date, :out_date
    )
  end
end
