require 'json'

class SpotifyService
  SPOTIFY_MAX_LIMIT_PER_PAGE = 50

  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
    @spotify_user = current_user.spotify_user
  end

  # Retrieves the total number of artists followed by the current user from Spotify.
  #
  # This method makes a request to the Spotify API to fetch the total number of artists followed by the current user.
  #
  # @return [Integer] The total number of artists followed by the current user.
  def total_followed_artists
    RSpotify.raw_response = true
    count = JSON.parse(@current_user.spotify_user.following(type: 'artist'))["artists"]["total"]
    RSpotify.raw_response = false

    count
  rescue => e
    Rails.logger.error("Unexpected error when fetching total followed artists from Spotify: #{e.message}")
  end

  # TODO: [⚡️Performance Tip] I should :
  #         # - add an attribute spotify_id to Artist
  #         # - create a table index on spotify_id
  #         # - do the find_or_create_by on artist.spotify_id
  #         # Peformance will be better by searching on an Integer than on a String
  # Fetches artists from Spotify and loads them into the database, associating them with the current user.
  #
  # @return [void]
  def fetch_and_load_artists
    ActiveRecord::Base.transaction do
      # Fetch current user's followed artists
      fetched_artists = fetch_artists

      # TODO: Group these two methods in a method called create_new_artists
      # Get new artists to be created and not already existing in the DB
      spotify_artists_to_create = artists_to_create_in_db(fetched_artists)
      # Insert new artists in the DB
      create_artists_in_db(spotify_artists_to_create)

      # TODO: Group these three methods in a method called follow_new_artists
      # TODO: There may be an extra step here that could be optimized...
      # Get the uniq artists not already followed by the user
      new_artists_to_follow = artists_to_follow(fetched_artists)
      # Fetch artist IDs for newly created and existing artists
      artist_ids_to_follow = Artist.where(name: new_artists_to_follow.map(&:name)).pluck(:id)
      # Attach new artists to the current user
      @current_user.followed_artists.create!(artist_ids_to_follow.map { |artist_id| { artist_id: artist_id } })

      # Remove unfollowed artists
      remove_unfollowed_artists(fetched_artists)
    end
  end

  private

  # Fetches all followed artists of the current user from Spotify.
  #
  # This method retrieves all followed artists of the current user from Spotify in batches until either the total number
  # of fetched artists reaches the total number of followed artists or the maximum loop count is exceeded.
  #
  # @return [Array<Artist>] An array containing all fetched artists.
  def fetch_artists
    artists = []
    max_loop = 0

    loop do
      max_loop += 1
      batch_of_fetched_artists = fetch_batch_of_artists(artists.last&.id)
      artists.concat(batch_of_fetched_artists)

      # Break the loop if:
      # - The batch of fetched artists is empty.
      # - The total number of fetched artists exceeds or equals the total number of followed artists.
      # - The maximum loop count exceeds 100.
      break if batch_of_fetched_artists.empty? || artists.size >= total_followed_artists || max_loop > 100
    end

    artists
  end

  # Use Spotify's API to fetch a batch of followed artists for current_user
  #
  # @param last_artist_id [String] The ID of the last artist in the previous batch
  # @return [RSpotify::Artist] An array of artists representing the batch of followed artists, or nil if an error occurs
  # TODO: Improve this method by returning an array of hash with only the extracted properties we are interested in :
  #   - name
  #   - url
  #   - cover
  #   - (to come: spotify_id)
  #   - (to come: genres)
  def fetch_batch_of_artists(last_artist_id)
    @current_user.spotify_user.following(type: 'artist', limit: SPOTIFY_MAX_LIMIT_PER_PAGE, after: last_artist_id)
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Error fetching batch of artists from Spotify: #{e.message}")
    nil
  end

  # Filter out artists from the fetched list that are not already present in the database.
  #
  # This method takes an array of fetched artists and compares their names with
  # the names of artists already existing in the database. It returns a new array
  # containing only the artists from the fetched list that are not present in the database.
  #
  # @param fetched_artists [Array<Artist>] An array of artists fetched from an external source.
  # @return [Array<Artist>] An array of artists to be created in the database.
  # TODO: Try to improve this method by searching existing artists by their Spotify_id rather than their names
  def artists_to_create_in_db(fetched_artists)
    existing_artist_names = Artist.where(name: fetched_artists.map(&:name)).pluck(:name)
    fetched_artists.reject { |followed_artist| existing_artist_names.include?(followed_artist.name) }
  end

  # Filter out new followed artists from the fetched list that are not already linked to the user.
  #
  # This method takes an array of fetched artists and compares their names with
  # the names of artists already followed by the current user. It returns a new array
  # containing only the artists from the fetched list that are not already followed by the user.
  #
  # @param fetched_artists [Array<Artist>] An array of artists fetched from an external source.
  # @return [Array<Artist>] An array of new artists to be followed by the user.
  # TODO: Try to improve this method by searching existing artists by their Spotify_id rather than their names
  def artists_to_follow(fetched_artists)
    existing_followed_artists_names = @current_user.artists.where(name: fetched_artists.map(&:name)).pluck(:name)
    fetched_artists.reject { |followed_artist| existing_followed_artists_names.include?(followed_artist.name) }
  end

  # TODO: Use gem active import to manage insert_all
  def create_artists_in_db(spotify_artists_to_create)
    unless spotify_artists_to_create.empty?
      Artist.insert_all(spotify_artists_to_create.map { |artist| { name: artist.name, external_link: artist.uri, cover_url: artist.images.last&.dig("url") }  }, unique_by: :name)
    end
  end

  # Removes unfollowed artists from the current user's followed artists.
  #
  # @param all_followed_artists [Array<Artist>] the list of all followed artists fetched from Spotify
  # @return [void]
  def remove_unfollowed_artists(all_followed_artists)
    prev_followed_artist_names = @current_user.artists.pluck(:name)
    new_followed_artists_names = all_followed_artists.map(&:name)
    artists_names_to_unfollow = prev_followed_artist_names - new_followed_artists_names

    return if artists_names_to_unfollow.empty?

    artists_ids_to_delete = @current_user.artists.where(name: artists_names_to_unfollow).pluck(:id)
    @current_user.followed_artists.where(artist_id: artists_ids_to_delete).destroy_all
  end
end