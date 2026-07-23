class ProductionPartiesController < ApplicationController
  before_action :require_login
  before_action :require_section
  before_action :block_view_only, only: %i[new create edit update destroy]
  before_action :set_party, only: %i[show edit update destroy]

  def index; @parties = ProductionParty.with_attached_photo.with_attached_cnic_front.with_attached_cnic_back; end
  def new;   @party = ProductionParty.new; end
  def show; end
  def edit; end

  def create
    @party = ProductionParty.new(party_params)
    if @party.save
      sync_advance(@party, params.dig(:production_party, :advance_payment))
      redirect_to production_parties_path, notice: "Production party added."
    else render :new, status: :unprocessable_entity end
  end

  def update
    @party.photo.purge if params.dig(:production_party, :remove_photo) == "1"
    if @party.update(party_params)
      sync_advance(@party, params.dig(:production_party, :advance_payment))
      redirect_to production_parties_path, notice: "Updated."
    else render :edit, status: :unprocessable_entity end
  end

  def destroy
    @party.destroy
    redirect_to production_parties_path, notice: "Removed."
  end

  private

  # Onboarding advance = a flagged stitching payment. Create/update/remove it to match the field.
  # It counts as "paid", so it credits the party now and is deducted from their stitching work.
  def sync_advance(party, raw)
    return if raw.nil?
    amt = raw.to_f.round(2)
    adv = party.advance_payment
    if amt > 0
      if adv then adv.update!(amount: amt)
      else party.stitching_payments.create!(amount: amt, advance: true, paid_on: Date.current,
                                            method_detail: "Advance (onboarding)") end
    elsif adv
      adv.destroy
    end
  end

  def set_party; @party = ProductionParty.find(params[:id]); end
  def party_params; params.require(:production_party).permit(:name, :contact, :family_contact, :notes, :photo, :cnic_front, :cnic_back); end
  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Production Parties." unless current_user.can_see?("prod_party")
  end
  def block_view_only
    redirect_to production_parties_path, alert: "View-only users cannot edit." if current_user.view_only?
  end
end
