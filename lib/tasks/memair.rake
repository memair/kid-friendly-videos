require "#{Rails.root}/app/helpers/memair_helper"
include MemairHelper

namespace :memair do
  desc "Make new recommendations"
  task :make_recommendations => :environment do
    puts "started at #{DateTime.now}"
    user = User.where('last_recommended_at IS NULL OR last_recommended_at < ?', 24.hours.ago).order('last_recommended_at ASC NULLS FIRST').first
    if user
      puts "recommending for #{user.email}"

      recommendations = []
      videos = Video.order("RANDOM()").limit(10)
      puts "#{videos.count} videos collected"
      videos.each do |video|
        recommendations << Recommendation.new(video: video, priority: 50, expires_at: 'tomorrow')
      end
      mutation = generate_recommendation_mutation(recommendations)
      response = Memair.new(user.memair_access_token).query(mutation)
      puts "Bulk Create: #{response['data']['BulkCreate']['id']}"
      user.last_recommended_at = DateTime.now
      user.save
    else
      puts "no users requiring recommending"
    end
    puts "finished at #{DateTime.now}"
  end
end