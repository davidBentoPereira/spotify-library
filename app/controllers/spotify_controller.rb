class SpotifyController < ApplicationController
  # TODO: This should be a "create" action like in "create a spotify session", no ?
  def show
    # Get Spotify's user data
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])

    # Save User's Spotify data
    current_user.update(spotify_data: spotify_user.as_json)

    # Sync artists
    SyncFollowedArtistsJob.perform_async(current_user.id)

    if current_user.save
      redirect_to(root_path, notice: I18n.t("login.spotify.success"))
    else
      redirect_to(root_path, alert: I18n.t("login.spotify.error"))
    end
  end
end
