class DesignsController < ApplicationController
  before_action :require_login
  before_action :block_view_only
  before_action :set_design, only: %i[edit update destroy]
  before_action :load_cost_cards, only: %i[new create edit update]

  def new
    @design = Design.new
    @design.design_variants.build(size: "24", repeats_per_color: nil,
      trousers: nil, back: nil, bazoo: nil, kali: nil, falas: nil)
  end

  def create
    @design = Design.new(design_params)
    if @design.save
      redirect_to master_data_path(tab: "designs"), notice: "Design added."
    else
      @design.design_variants.build if @design.design_variants.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @design.update(design_params)
      redirect_to master_data_path(tab: "designs"), notice: "Design updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @design.destroy
    redirect_to master_data_path(tab: "designs"), notice: "Design removed."
  end

  private

  def set_design
    @design = Design.find(params[:id])
  end

  def load_cost_cards
    @cost_cards = CostCard.includes(picture_attachment: :blob).order(:code)
    # codes already turned into a Design — excluded from the picker so you can't add duplicates
    @used_design_codes = Design.where.not(id: @design&.id).pluck(:code)
  end

  def block_view_only
    redirect_to master_data_path, alert: "View-only users cannot edit." if current_user.view_only?
  end

  def design_params
    params.require(:design).permit(
      :code,
      design_variants_attributes: [
        :id, :size, :repeats_per_color, :trousers, :back, :bazoo, :kali, :falas, :_destroy,
        { variant_components_attributes: %i[id name value _destroy] }
      ]
    )
  end
end
