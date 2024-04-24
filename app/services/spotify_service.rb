require 'open-uri'

class SpotifyService
  SPOTIFY_MAX_LIMIT_PER_PAGE = 50
  MAX_LOOP = 10

  def initialize(spotify_user)
    @spotify_user = spotify_user
  end

  # Retrieves the total number of artists followed by the current user from Spotify.
  #
  # This method makes a request to the Spotify API to fetch the total number of artists followed by the current user.
  #
  # @return [Integer] The total number of artists followed by the current user.
  def total_followed_artists
    RSpotify.raw_response = true
    count = JSON.parse(@spotify_user.following(type: 'artist'))["artists"]["total"]
    RSpotify.raw_response = false

    count
  rescue => e
    Rails.logger.error("Unexpected error when fetching total followed artists from Spotify: #{e.message}")
  end

  # This method fetches all followed artists of the current user from Spotify and converts them into an array of Artist
  # objects.
  #
  # @return [Array<Artist>] An array containing all fetched artists.
  def artists
    fetch_all_followed_artists.map do |a|
      Artist.new(
        name: a.name,
        external_link: a.uri,
        cover_url: a.images.last&.dig("url")
      )
    end
  end

  private

  # Fetches all followed artists of the current user from Spotify.
  #
  # This method retrieves all followed artists of the current user from Spotify in batches until either the total number
  # of fetched artists reaches the total number of followed artists or the maximum loop count is exceeded.
  #
  # @return [Array<Artist>] An array containing all fetched artists.
  def fetch_all_followed_artists
    artists = []
    count_loop = 0

    loop do
      count_loop += 1
      batch_of_fetched_artists = fetch_batch_of_followed_artists(artists.last&.id)
      artists.concat(batch_of_fetched_artists)

      # Break the loop if:
      # - The batch of fetched artists is empty.
      # - The total number of fetched artists exceeds or equals the total number of followed artists.
      # - The maximum loop count exceeds 100.
      break if batch_of_fetched_artists.empty? || artists.size >= total_followed_artists || count_loop > MAX_LOOP
    end

    artists
  end

  # Fetches a batch of followed artists for the current user from the Spotify API.
  #
  # @param last_artist_id [String] The ID of the last artist in the previous batch.
  # @return [Array<RSpotify::Artist>, nil] An array of artists representing the batch of followed artists,
  #   or nil if an error occurs during the request.
  def fetch_batch_of_followed_artists(last_artist_id)
    @spotify_user.following(type: 'artist', limit: SPOTIFY_MAX_LIMIT_PER_PAGE, after: last_artist_id)
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Error fetching batch of artists from Spotify: #{e.message}")
    nil
  end
end