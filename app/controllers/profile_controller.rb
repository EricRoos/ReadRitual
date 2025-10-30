class ProfileController < ApplicationController
  def show
  end

  def update
    if Current.user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :books_per_year_goal)
  end
end
