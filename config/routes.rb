Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users

  # Defines the root path route ("/")
  root "home#index"

  #   #############################################
  #  ############### Canonical Routes ############
  # #############################################
  resources :home, only: [:index]
  namespace :spotify do
    resources :session, only: [:create]
    resources :artist, only: [:create]
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


  # #########################################
  #  #########################################
  #   #########################################

  # Used by Spotify to redirect after Sign In
  # TODO: We could redirect directly to HomeController#index ?
  get "/auth/spotify/callback", to: "spotify/session#create"
end
