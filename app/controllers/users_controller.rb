include MemairHelper

class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update_attributes(user_params)
      flash[:success] = 'Settings have being saved'
    else
      flash[:error] = 'Something went wrong'
    end
    redirect_to(root_path)
  end

  def watch_time
    minutes = params[:watch_time].to_i
    errors.add(:yt_id, "Please select a longer time period") if minutes < 5
    recommendations = current_user.get_recommendations(minutes)

    mutation = generate_recommendation_mutation(recommendations)
    response = Memair.new(current_user.memair_access_token).query(mutation)
    flash[:success] = "#{recommendations.count} #{'video'.pluralize(recommendations.count)} added to your Memair play list which will expire in #{minutes} minutes."
    redirect_to(root_path)
  end

  private
    def user_params
      params.require(:user).permit(:functioning_age, :daily_watch_time, interests: [])
    end 
end
