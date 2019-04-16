class Channel < ApplicationRecord
  validates :yt_id, uniqueness: true
  validates_numericality_of :min_age, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, message: 'must be between 0 & 100'
  validates_numericality_of :max_age, :greater_than => :min_age, message: 'must be greater than min age'
  validates_numericality_of :max_age, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, message: 'must be between 0 & 100'

  attr_accessor :channel_url

  before_validation :get_yt_id
  before_save :set_details_if_nil

  has_many :videos, dependent: :delete_all

  def get_videos
    yt_channel.videos.where(published_after: latest_published_at, published_before: DateTime.now.utc.iso8601(0)).each do |yt_video|
      begin
        if yt_video.duration.to_i > 0
          self.videos.where(yt_id: yt_video.id).first_or_create do |video|
            video.yt_id        = yt_video.id
            video.title        = yt_video.title
            video.description  = yt_video.description
            video.tags         = yt_video.tags
            video.published_at = yt_video.published_at
            video.duration     = yt_video.duration
          end
        end
      rescue Yt::Errors::NoItems
        # ignore live videos that fail
      end
    end
  end

  def update_details
    self.update_attributes(
      title: yt_channel.title,
      description: yt_channel.description,
      thumbnail_url: yt_channel.thumbnail_url
    )
  end

  private
    def yt_channel
      @yt_channel = @yt_channel || (Yt::Channel.new id: self.yt_id)
    end

    def latest_published_at
      if self.videos.empty?
        DateTime.new(2005, 2, 14)
      else
        self.videos.maximum(:published_at).iso8601(0)
      end
    end

    def set_details_if_nil
      self.title = self.title || yt_channel.title
      self.description = self.description || yt_channel.description
      self.thumbnail_url = self.thumbnail_url || yt_channel.thumbnail_url
    end

    def get_yt_id
      if self.channel_url
        response = HTTParty.get(self.channel_url, timeout: 180)
        matches = /yt.setConfig\('CHANNEL_ID', "(([a-z]|[A-Z]|\d|-|_){24})"\);/.match(response.body)
        self.yt_id = matches[1] unless matches.nil?
      end
      errors.add(:yt_id, "Please provide correct url or yt_id") unless self.yt_id
    end
end
