class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    if current_user.spotify_data?
      @spotify_user = RSpotify::User.new(current_user.spotify_data)

      # @followed_artists = @spotify_user.following(type: 'artist', limit: 50, after: "1EevBGfUh3RSQSGpluxgBm")
      @followed_artists = @spotify_user.following(type: 'artist', limit: 50)
    end
  end
end
