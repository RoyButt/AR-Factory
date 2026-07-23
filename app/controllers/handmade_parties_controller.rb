class HandmadePartiesController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[new create edit update destroy]
  before_action :set_party, only: %i[show edit update destroy]

  def index; @parties = HandmadeParty.with_attached_image; end
  def show; end
  def new;  @party = HandmadeParty.new; end
  def edit; end

  def create
    @party = HandmadeParty.new(party_params)
    if @party.save then redirect_to handmade_parties_path, notice: "Party added."
    else render :new, status: :unprocessable_entity end
  end

  def update
    if @party.update(party_params) then redirect_to handmade_parties_path, notice: "Party updated."
    else render :edit, status: :unprocessable_entity end
  end

  def destroy
    @party.destroy
    redirect_to handmade_parties_path, notice: "Party removed."
  end

  private
  def set_party; @party = HandmadeParty.find(params[:id]); end
  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Handmade Party." unless current_user.can_see?("handmade_party")
  end
  def block_view_only
    redirect_to handmade_parties_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
  def party_params
    params.require(:handmade_party).permit(:name, :contact, :email, :address, :city, :notes, :image)
  end
end
