namespace :youtube do
  desc "Get new videos from YouTube"
  task :get_videos => :environment do
    puts "started at #{DateTime.now}"
    channel = Channel.order('last_extracted_at ASC NULLS FIRST').first
    puts "updating #{channel.title}"
    channel.get_videos
    channel.last_extracted_at = DateTime.now
    channel.save
    puts "finished at #{DateTime.now}"
  end
end