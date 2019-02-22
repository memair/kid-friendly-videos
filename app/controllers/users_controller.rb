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
    recommendations = current_user.get_recommendations(
      expires_in: params[:expires_in].to_i,
      watch_time: params[:watch_time].to_i,
      priority: 95
    )

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
