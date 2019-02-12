require 'test_helper'
require 'mocha'

class UserTest < ActiveSupport::TestCase

  setup do
    @user = users(:young_child)
  end

  test "young user receives age appropriate recommendations" do
    previous_recommended = []
    User.any_instance.stubs(:previous_recommended).returns(previous_recommended)
    recommendations = @user.get_recommendations

    recommendations.each do |recommendation|
      channel = recommendation.video.channel
      assert @user.functioning_age.between?(channel.min_age, channel.max_age)
    end
  end

  test "young user's recommendations respect daily_watch_time" do
    previous_recommended = []
    User.any_instance.stubs(:previous_recommended).returns(previous_recommended)
    recommendations = @user.get_recommendations

    recommendation_duration = recommendations.map { |r| r.video.duration }.sum
    assert recommendation_duration <= @user.daily_watch_time
  end

  test "young user does not recieve recently recommended videos" do
    previous_recommended = [videos(:cat_video_1).yt_id, videos(:cat_video_2).yt_id]
    User.any_instance.stubs(:previous_recommended).returns(previous_recommended)
    recommendations = @user.get_recommendations

    recommendations.each do |recommendation|
      refute previous_recommended.include? recommendation.video.yt_id
    end
  end
end



