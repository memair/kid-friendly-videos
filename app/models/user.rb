class User < ApplicationRecord
  before_destroy :revoke_token

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:memair]

  INTERESTS = %w(trains songs minecraft animals history science)
  ADMINS = %w( greg@gho.st )

  def admin
    ADMINS.include? self.email
  end

  def self.from_memair_omniauth(omniauth_info)
    data        = omniauth_info.info
    credentials = omniauth_info.credentials

    user = User.where(email: data['email']).first

    unless user
     user = User.create(
       email:    data['email'],
       password: Devise.friendly_token[0,20]
     )
    end

    user.memair_access_token = credentials['token']
    user.save
    user
  end

  def get_recommendations
    previous_recommended_video_ids = Video.where(yt_id: previous_recommended).ids

    sql = """
      WITH
      recommendable_videos AS (
        SELECT
          v.id,
          50 AS priority,
          '#{DateTime.now + 48.hours}'::text AS expires_at,
          SUM(v.duration) OVER (ORDER BY RANDOM()) AS cumulative_duration
        FROM
          videos v
          JOIN channels c ON v.channel_id = c.id
        WHERE
          v.duration < #{self.daily_watch_time / 2}
          AND v.duration > 0
          AND #{self.functioning_age} BETWEEN c.min_age AND c.max_age
          #{'AND v.id NOT IN (' + previous_recommended_video_ids.join(",") + ')' unless previous_recommended_video_ids.empty?}
        ORDER BY RANDOM()
        LIMIT 50)
      SELECT *
      FROM recommendable_videos
      WHERE cumulative_duration <= #{self.daily_watch_time}
    """

    results = ActiveRecord::Base.connection.execute(sql).to_a
    recommendations = results.map {|r| Recommendation.new(video: Video.find(r['id']), priority: r['priority'], expires_at: r['expires_at'])}
  end

  def setup?
    !self.functioning_age.nil? && !self.daily_watch_time.nil?
  end
  
  private
    def revoke_token
      user = Memair.new(self.memair_access_token)
      query = 'mutation {RevokeAccessToken{revoked}}'
      user.query(query)
    end

    def previous_recommended
      query = '''
        query{
          recommended: Recommendations(first: 10000 actioned: true order: desc order_by: timestamp){url}
        }'''
      response = Memair.new(self.memair_access_token).query(query)
      response['data']['recommended'].map{|r| youtube_id(r['url'])}.compact.uniq
    end

    def youtube_id(url)
      regex = /(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
      matches = regex.match(url)
      matches[1] unless matches.nil?
    end
end
