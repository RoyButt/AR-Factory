class CostCardsController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[new create edit update destroy rotate_image]
  before_action :set_card, only: %i[show edit update destroy rotate_image]

  def index
    @cards = CostCard.includes(:emb_files, picture_attachment: :blob).order(:code)
  end

  def show; end

  def new
    @card = CostCard.new(code: "AR-", fabric_rate: 325, fabric_multiplier: 3.5, cmt: 325, cm: 150)
    @card.emb_files.build
    @card.card_addons.build(target: "emb",   label: "EMB add-on",         amount: Setting.value_for("emb_addon", 25))
    @card.card_addons.build(target: "final", label: "Margin / round-off", amount: Setting.value_for("final_addon", 100))
    @existing_codes = CostCard.pluck(:code)
  end

  def create
    @card = CostCard.new(card_params)
    if @card.save
      redirect_to cost_card_path(@card), notice: "Cost card created."
    else
      @card.emb_files.build if @card.emb_files.empty?
      @existing_codes = CostCard.pluck(:code)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @existing_codes = CostCard.where.not(id: @card.id).pluck(:code)
  end

  def update
    if @card.update(card_params)
      redirect_to cost_card_path(@card), notice: "Cost card updated."
    else
      @existing_codes = CostCard.where.not(id: @card.id).pluck(:code)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    redirect_to cost_cards_path, notice: "Cost card removed."
  end

  # Rotate the attached product image 90° and re-save it (permanent).
  def rotate_image
    unless @card.picture.attached?
      return redirect_to(edit_cost_card_path(@card), alert: "No image to rotate.")
    end
    deg = params[:deg].to_i
    deg = 90 unless [90, -90, 180, 270].include?(deg)
    blob = @card.picture.blob
    ext  = blob.filename.extension.presence || "png"
    require "tmpdir"
    Dir.mktmpdir do |dir|
      src = File.join(dir, "in.#{ext}")
      out = File.join(dir, "out.#{ext}")
      File.binwrite(src, @card.picture.download)
      ok = system("magick", src, "-rotate", deg.to_s, out)
      raise "rotate failed" unless ok && File.exist?(out) && File.size(out).positive?
      @card.picture.attach(io: File.open(out), filename: blob.filename.to_s,
                           content_type: blob.content_type.presence || "image/png")
    end
    redirect_to edit_cost_card_path(@card), notice: "Image rotated #{deg}°."
  rescue => e
    Rails.logger.error("rotate_image failed: #{e.class} #{e.message}")
    redirect_to edit_cost_card_path(@card), alert: "Could not rotate the image."
  end

  private

  def set_card
    @card = CostCard.find(params[:id])
  end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Cost Cards." unless current_user.can_see?("costing")
  end

  def block_view_only
    redirect_to cost_cards_path, alert: "View-only users cannot edit." if current_user.view_only?
  end

  def card_params
    params.require(:cost_card).permit(
      :code, :fabric_rate, :fabric_multiplier, :cmt, :cut_work, :hand_made, :cm, :lass, :card_date, :picture,
      emb_files_attributes: %i[id sr file_name stitch heads reapts rate _destroy],
      cost_lines_attributes: %i[id name amount _destroy],
      card_addons_attributes: %i[id target label amount _destroy],
      party_prices_attributes: %i[id party_name pricing_mode value note _destroy]
    )
  end
end
