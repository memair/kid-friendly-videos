Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get "/auth/:action/callback", controller: "authentications", constraints: { action: /memair/ }
  end

  resources :users

  root 'static_pages#home'
  get  'channels' => 'channels#index'
end
