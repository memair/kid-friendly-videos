class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :correct_user

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'Settings have being saved'
    else
      flash[:error] = 'Something went wrong'
    end
    redirect_to(root_path)
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def correct_user
      redirect_to(root_url) unless current_user == @user
    end

    def user_params
      params.require(:user).permit(:functioning_age, :daily_watch_time, tags: [])
    end 
end
