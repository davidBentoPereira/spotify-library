begin
  require 'rspotify/oauth'

  SCOPE = [
    # "ugc-image-upload",
    # "user-read-playback-state",
    # "user-modify-playback-state",
    # "user-read-currently-playing",
    # "app-remote-control",
    # "streaming",
    # "playlist-read-private",
    # "playlist-read-collaborative",
    # "playlist-modify-private",
    # "playlist-modify-public",
    # "user-follow-modify",
    "user-follow-read",
    # "user-read-playback-position",
    "user-top-read",
    "user-read-recently-played",
    "user-library-modify",
    "user-library-read",
    "user-read-email",
    "user-read-private",
    # "user-soa-link",
    # "user-soa-unlink",
    # "user-manage-entitlements",
    # "user-manage-partner",
    # "user-create-partner"
  ]

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :spotify, ENV['SPOTIFY_CLIENT_ID'], ENV['SPOTIFY_CLIENT_SECRET'], scope: SCOPE.join(" ")
  end

  OmniAuth.config.allowed_request_methods = [:post, :get]
rescue RestClient::BadRequest => e
  error_message = "=======\n" \
    "Missing Spotify client credentials. Please enter SPOTIFY_CLIENT_ID\n" \
    "and SPOTIFY_CLIENT_SECRET in config/env.yml.\n" \
    "======="
  logger.error(error_message)
end
