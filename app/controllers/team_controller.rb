class TeamController < ApplicationController
  before_action :require_login
  before_action :require_team_access
  before_action :set_user, only: %i[edit update destroy]

  def index
    @users = User.order(:role, :name)
  end

  def new
    @user = User.new(role: "operator", view_only: true, allowed_sections: %w[dashboard])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to team_index_path, notice: "#{@user.name} added to the team."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    attrs = user_params
    attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
    if @user.update(attrs)
      redirect_to team_index_path, notice: "#{@user.name} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to team_index_path, alert: "You can't delete your own account."
    else
      @user.destroy
      redirect_to team_index_path, notice: "#{@user.name} removed."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_team_access
    redirect_to dashboard_path, alert: "Only Super Admin / Admin can manage the team." unless current_user.can_manage_team?
  end

  def user_params
    permitted = params.require(:user).permit(
      :name, :email, :role, :view_only, :password, :password_confirmation,
      allowed_sections: []
    )
    permitted[:allowed_sections] = Array(permitted[:allowed_sections]).reject(&:blank?)
    permitted
  end
end
