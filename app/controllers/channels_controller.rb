class ChannelsController < ApplicationController
  before_action :auth_user
  before_action :authenticate_admin
  before_action :set_channel,  only: [:update, :destroy]

  def index
    @channels = Channel.all.sort_by{ |channel| channel.title.downcase }
    @channel = Channel.new
  end

  def create
    if @channel = Channel.create(channel_params)
      flash[:success] = "updated #{@channel.title}"
    else
      flash[:error] = @channel.errors.full_messages
    end
    redirect_to channels_path
  end

  def update
    if @channel.update(channel_params)
      flash[:success] = "updated #{@channel.title}"
    else
      flash[:error] = @channel.errors.full_messages
    end
    redirect_to channels_path
  end

  def destroy
    @channel.destroy
    flash[:success] = "#{@channel.title} deleted"
    redirect_to channels_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_params
      params.permit(:max_age, :min_age, :channel_url, tags: [])
    end

    def authenticate_admin
      unless current_user.admin
        redirect_to root_path
      end
    end
  
    def auth_user
      redirect_to root_path unless user_signed_in?
    end
end
