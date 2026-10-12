class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user   = current_user
    @recent = current_user.uploads.recent.limit(8)

    @stats = {
      photos:    current_user.uploads.count,
      albums:    current_user.albums.count,
      tags:      current_user.tags.count,
      favorites: current_user.uploads.favorites.count
    }
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "Профиль обновлён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :bio, :avatar)
  end
end