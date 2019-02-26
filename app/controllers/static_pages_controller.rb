class StaticPagesController < ApplicationController
  before_action :flash_notice

  def home
    flash[:notice] = "Update your child's deatils below to start recommendations" if !!current_user && !current_user.setup?
  end

  def flash_notice
  end
end
