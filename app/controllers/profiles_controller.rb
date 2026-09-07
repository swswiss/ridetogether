class ProfilesController < ApplicationController
  layout "dashboard"

  def show
    @user = Current.user
    @groups = @user.groups.count
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if password_change_requested?
      unless @user.authenticate(params[:user][:current_password])
        @user.errors.add(:current_password, "este incorectă")
        return render :edit, status: :unprocessable_entity
      end
    end

    if @user.update(user_params)
      redirect_to edit_profile_path, notice: "Profilul a fost actualizat."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email_address,
      :city,
      :password
    )
  end

  def password_change_requested?
    params[:user][:password].present?
  end
end