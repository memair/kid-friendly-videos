include MemairHelper

class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    completing_signup = current_user.functioning_age.nil? && current_user.daily_watch_time.nil?

    if current_user.update_attributes(user_params)
      if completing_signup
        recommendations = current_user.get_recommendations(
          expires_in: 25 * 60,
          watch_time: current_user.daily_watch_time,
          priority: 50
        )
        mutation = generate_recommendation_mutation(recommendations)
        Memair.new(current_user.memair_access_token).query(mutation)
        current_user.update(last_recommended_at: DateTime.now)
        flash[:success] = "Setup is complete, Launch Player to see your first recommendations. #{current_user.daily_watch_time} minutes of videos will be added to Memair player every 24 hours. Return to this app to update your preferences or to add additional reward recommendations"
      else
        flash[:success] = "Settings have being saved, updated recommendations will start appearing on Memair shortly"
      end
    else
      flash[:error] = 'Something went wrong'
    end
    redirect_to(root_path)
  end

  def watch_time
    recommendations = current_user.get_recommendations(
      expires_in: params[:expires_in].to_i,
      watch_time: params[:watch_time].to_i,
      priority: 95
    )

    mutation = generate_recommendation_mutation(recommendations)
    response = Memair.new(current_user.memair_access_token).query(mutation)
    flash[:success] = "#{recommendations.count} #{'video'.pluralize(recommendations.count)} added to Memair player which will expire in #{params[:expires_in]} minutes. Click Launch Player below to enjoy them!"
    redirect_to(root_path)
  end

  private
    def user_params
      params.require(:user).permit(:functioning_age, :daily_watch_time, interests: [])
    end 
end
