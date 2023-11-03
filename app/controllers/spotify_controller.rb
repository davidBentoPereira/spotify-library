class SpotifyController < ApplicationController
  def show
    # Get Spotify's user data
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])

    # Save User's spotify data
    current_user.update(spotify_data: spotify_user.as_json)

    # Save artists
    SpotifyService.new(spotify_user).load_artists

    if current_user.save
      # Redirect to homepage with a flash message
      redirect_to(root_path, notice: I18n.t("login.spotify.success"))
    else
      # Redirect to homepage with a flash message
      redirect_to(root_path, alert: I18n.t("login.spotify.error"))
    end
  end
end
