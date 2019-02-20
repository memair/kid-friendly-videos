include Devise::OmniAuth::UrlHelpers

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :memair, ENV['MEMAIR_CLIENT_ID'], ENV['MEMAIR_CLIENT_SECRET'], scope: 'digital_activity_read recommendation_write recommendation_read'
end
