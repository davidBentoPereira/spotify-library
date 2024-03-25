Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users

  # Defines the root path route ("/")
  root "home#index"

  #   #############################################
  #  ############### Canonical Routes ############
  # #############################################
  resources :home, only: [:index]
  resources :spotify, only: [:show]

  #   ###########################################
  #  ############### Custom Routes #############
  # ###########################################
  # Custom routes start here
  # For each new custom route:
  # * Be sure you have the canonical route declared above
  # * Add the new custom route below the existing ones
  # * Document why it's needed
  # * Explain anything else non-standard

  post "sync_spotify_followed_artists", to:"home#sync_spotify_followed_artists"

  # #########################################
  #  #########################################
  #   #########################################

  # Used by Spotify to redirect after Sign In
  # TODO: We could redirect directly to HomeController#index ?
  get "/auth/spotify/callback", to: "spotify#show"
end
