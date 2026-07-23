class EmbPartiesController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[new create edit update destroy]
  before_action :set_party, only: %i[show edit update destroy]

  def index
    @parties = EmbParty.with_attached_image
  end

  def show; end

  def new
    @party = EmbParty.new
  end

  def create
    @party = EmbParty.new(party_params)
    if @party.save
      redirect_to emb_parties_path, notice: "Party added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @party.update(party_params)
      redirect_to emb_parties_path, notice: "Party updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @party.destroy
    redirect_to emb_parties_path, notice: "Party removed."
  end

  private

  def set_party
    @party = EmbParty.find(params[:id])
  end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Emb Party." unless current_user.can_see?("emb_party")
  end

  def block_view_only
    redirect_to emb_parties_path, alert: "View-only users cannot edit." if current_user.view_only?
  end

  def party_params
    params.require(:emb_party).permit(:name, :contact, :email, :address, :city, :notes, :image)
  end
end
