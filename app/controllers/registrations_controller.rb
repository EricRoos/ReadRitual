class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 5, within: 1.hour, only: :create, with: -> { redirect_to new_registration_url, alert: "Too many registration attempts. Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Welcome to ReadRitual! Your account has been created."
    else
      render :new, status: :unprocessable_content
    end
  end

  protected

  def show_bottom_nav?
    false
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :books_per_year_goal)
  end
end
