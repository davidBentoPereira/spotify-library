class MissingSpotifyDataError < StandardError
  def initialize(msg = "User is missing spotify_data.")
    super
  end
end