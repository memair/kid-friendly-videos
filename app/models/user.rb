class User < ApplicationRecord
  before_destroy :revoke_token

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:memair]

  INTERESTS = [
    'Trains & Machines',
    'Science & Technology',
    'Cartoons & Puppets',
    'Songs & Music',
    'Movement & Dance',
    'Crafts & Creative',
    'Maths',
    'Education',
    'Reading',
    'Stories & Riddles',
    'Blogs',
    'News',
    'Environment & Animals',
    'Computer Games'
  ]
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

  def get_recommendations(expires_in=nil, priority=50)
    previous_recommended_video_ids = Video.where(yt_id: previous_recommended).ids

    sql = """
      WITH
      recommendable_channels AS (
        SELECT
          c.id,
          CASE WHEN (u.interests ?| TRANSLATE(c.tags::text, '[]','{}')::TEXT[]) THEN 0 ELSE 1 END AS interest_match,
          c.thumbnail_url
        FROM
          users u
          JOIN channels c ON u.functioning_age BETWEEN c.min_age AND c.max_age
        WHERE u.id = #{self.id}
        GROUP BY c.id, u.interests, c.thumbnail_url
      ),
      recommendable_videos AS (
        SELECT
          v.id,
          c.thumbnail_url,
          v.published_at,
          v.duration,
          (NOW() + INTERVAL '#{ expires_in || 48 * 60 }' MINUTE)::text AS expires_at,
          SUM(v.duration) OVER (ORDER BY c.interest_match, RANDOM()) AS cumulative_duration
        FROM
          videos v
          JOIN recommendable_channels c ON v.channel_id = c.id
        WHERE
          v.duration < #{ expires_in.nil? ? self.daily_watch_time * 60 / 2 : expires_in * 60 }
          AND v.duration > 0
          #{'AND v.id NOT IN (' + previous_recommended_video_ids.join(",") + ')' unless previous_recommended_video_ids.empty?}
        ORDER BY c.interest_match, RANDOM()
        LIMIT 50)
      SELECT *
      FROM recommendable_videos
      WHERE cumulative_duration <= #{ expires_in.nil? ? self.daily_watch_time * 60 : expires_in * 60 }
    """

    results = ActiveRecord::Base.connection.execute(sql).to_a
    videos = Video.where(id: results.map {|r| r['id']}) # prevent n + 1 query
    results.each_with_index.map { |r, idx| Recommendation.new(video: videos[idx], priority: priority, expires_at: r['expires_at'], thumbnail_url: r['thumbnail_url'], published_at: r['published_at'], duration: r['duration']) }
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
