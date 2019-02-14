class Channel < ApplicationRecord
  Gutentag::ActiveRecord.call self

  validates :yt_id, uniqueness: true
  validates_numericality_of :min_age, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, message: 'must be between 0 & 100'
  validates_numericality_of :max_age, :greater_than => :min_age, message: 'must be greater than min age'
  validates_numericality_of :max_age, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, message: 'must be between 0 & 100'

  before_save :set_details_if_nil
  has_many :videos, dependent: :delete_all

  def get_videos
    yt_channel.videos.each do |yt_video|
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

    def set_details_if_nil
      self.title = self.title || yt_channel.title
      self.description = self.description || yt_channel.description
      self.thumbnail_url = self.thumbnail_url || yt_channel.thumbnail_url
    end
end
