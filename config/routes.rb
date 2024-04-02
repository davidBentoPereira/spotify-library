Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users

  # Defines the root path route ("/")
  root "spotify/followed_artists#index"

  #   #############################################
  #  ############### Canonical Routes ############
  # #############################################
  namespace :spotify do
    resources :sessions, only: [:create]
    resources :followed_artists
  end


  #   ###########################################
  #  ############### Custom Routes #############
  # ###########################################
  # Custom routes start here
  # For each new custom route:
  # * Be sure you have the canonical route declared above
  # * Add the new custom route below the existing ones
  # * Document why it's needed
  # * Explain anything else non-standard

  # Used by Spotify to redirect after Sign In
  get "/auth/spotify/callback", to: "spotify/sessions#create"

  # #########################################
  #  #########################################
  #   #########################################
end
