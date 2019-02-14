namespace :youtube do
  desc "Get new videos from YouTube"
  task get_videos: :environment do
    puts "started at #{DateTime.now}"
    channel = Channel.order('last_extracted_at ASC NULLS FIRST').first
    puts "updating details for #{channel.title}"
    channel.update_details
    puts "getting videos for #{channel.title}"
    channel.get_videos
    channel.update_attributes(last_extracted_at: DateTime.now)
    puts "finished at #{DateTime.now}"
  end

  desc "Usage: rake youtube:add_channel[https://www.youtube.com/svcatsaway,15,99]"
  task :add_channel, [:url, :min_age, :max_age] => [:environment] do |task, args|
    puts "getting channel id for #{args[:url]}"
    response = HTTParty.get(args[:url], timeout: 180)
    channel_id = /yt.setConfig\('CHANNEL_ID', "(([a-z]|[A-Z]|\d|-|_){24})"\);/.match(response.body)[1]
    puts "Creating channel for channel_id: #{channel_id}"
    channel = Channel.create(yt_id: channel_id, min_age: args[:min_age].to_i, max_age: args[:max_age].to_i)
    if channel.valid?
      puts "#{channel.title} created"
    elsif Channel.find_by(yt_id: channel_id)
      channel = Channel.find_by(yt_id: channel_id)
      puts "#{channel.title} already exists updating min & max ages"
      channel.update_attributes(
        min_age: args[:min_age].to_i,
        max_age: args[:max_age].to_i
      )
      puts "updated min and max age for #{channel.title}"
    else
      puts "error: #{channel.errors.details.to_s}"
    end
  end
end