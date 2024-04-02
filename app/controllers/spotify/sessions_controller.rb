module Spotify
  class SessionsController < ApplicationController
    def create
      # Get Spotify's user data
      spotify_user = RSpotify::User.new(request.env['omniauth.auth'])

      # Save User's Spotify data
      current_user.update(spotify_data: spotify_user.as_json)

      # Fetch artists
      FetchArtistsJob.perform_async(current_user.id)

      if current_user.save
        redirect_to(root_path, notice: I18n.t("login.spotify.success"))
      else
        redirect_to(root_path, alert: I18n.t("login.spotify.error"))
      end
    end
  end
end