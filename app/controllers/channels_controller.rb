class ChannelsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin

  def index
    @channels = Channel.all
  end

  def authenticate_admin
    unless current_user.admin
      redirect_to new_user_session_path
    end
  end
end
