require 'test_helper'

class ChannelsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @user = users(:young_child)
    @admin = users(:admin)
  end

  test "should get redirected from index when not logged in" do
    get :index
    assert_redirected_to root_path
  end

  test "should get root path if not admin" do
    sign_in(@user)
    get :index
    assert_redirected_to root_path
  end

  test "should get index when admin" do
    sign_in(@admin)
    get :index
    assert_response :success
  end
end