module Spotify
  class ArtistController < ApplicationController
    def create
      SpotifyService.new(current_user).fetch_and_load_artists

      head :ok
    end
  end
end