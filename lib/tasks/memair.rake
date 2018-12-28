namespace :memair do
  desc "Make new recommendations"
  task :make_recommendations => :environment do
    puts "started at #{DateTime.now}"
    user = User.where('last_recommended_at IS NULL OR last_recommended_at < ?', 24.hours.ago).order('last_recommended_at ASC NULLS FIRST').first
    if user
      puts "recommending for #{user.email}"
      # make recommendations
      user.last_recommended_at = DateTime.now
      user.save
    else
      puts "no users requiring recommending"
    end
    puts "finished at #{DateTime.now}"
  end
end