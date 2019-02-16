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
    assert recommendation_duration <= @user.daily_watch_time * 60
  end

  test "young user does not recieve recently recommended videos" do
    previous_recommended = [videos(:cat_video_1).yt_id, videos(:cat_video_2).yt_id]
    User.any_instance.stubs(:previous_recommended).returns(previous_recommended)
    recommendations = @user.get_recommendations

    recommendations.each do |recommendation|
      refute previous_recommended.include? recommendation.video.yt_id
    end
  end

  test "child with song insterests should get song videos" do
    previous_recommended = []
    User.any_instance.stubs(:previous_recommended).returns(previous_recommended)
    user = users(:young_child_that_links_songs)
    recommendations = user.get_recommendations
    recommendations.each do |recommendation|
      assert recommendation.video.channel.tags.include?('songs')
    end
  end

  test "child with no selected insterests should get recommendations" do
    previous_recommended = []
    User.any_instance.stubs(:previous_recommended).returns(previous_recommended)
    user = users(:young_child_with_no_selected_interests)
    recommendations = user.get_recommendations

    refute recommendations.empty?
  end
end



