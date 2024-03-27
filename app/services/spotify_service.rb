require 'open-uri'

class SpotifyService
  MAX_ARTIST_PER_PAGE = 50

  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
    @spotify_user = current_user.spotify_user
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
      # Fetch all artist names already followed by the user
      followed_artist_names = @current_user.artists.pluck(:name)
      all_fetched_artists = []
      last_artist_id = nil
      number_of_artists_to_load = MAX_ARTIST_PER_PAGE

      while number_of_artists_to_load == MAX_ARTIST_PER_PAGE
        batch_of_fetched_artists = fetch_artists(last_artist_id)
        all_fetched_artists << batch_of_fetched_artists
        last_artist_id = batch_of_fetched_artists.last&.id
        number_of_artists_to_load = batch_of_fetched_artists.size

        # Collect new artists to be created in this batch
        # TODO: 🐛 Potential bug: We should reject the creation of artists already existing in the table Artists, not only those followed by the current_user
        spotify_artists_to_create = batch_of_fetched_artists.reject { |followed_artist| followed_artist_names.include?(followed_artist.name) }

        # Insert new artists in a single database query
        unless spotify_artists_to_create.empty?
          Artist.insert_all(spotify_artists_to_create.map { |artist| { name: artist.name, external_link: artist.uri, cover_url: artist.images.last&.dig("url") }  }, unique_by: :name)
        end

        # Fetch artist IDs for newly created and existing artists
        artist_ids = Artist.where(name: spotify_artists_to_create.map(&:name)).pluck(:id)

        # Attach new artists to the current user
        @current_user.followed_artists.create!(artist_ids.map { |artist_id| { artist_id: artist_id } })
      end

      remove_unfollowed_artists(all_fetched_artists, followed_artist_names)
    end
  end

  private

  # Use Spotify's API to fetch the following artists
  def fetch_artists(last_artist_id)
    @current_user.spotify_user.following(type: 'artist', limit: 50, after: last_artist_id)
  end

  # Removes unfollowed artists from the current user's followed artists.
  #
  # @param all_followed_artists [Array<Array<Artist>>] the list of all followed artists fetched from Spotify
  # @param previously_followed_artist_names [Array<String>] the list of names of artists previously followed by the user
  # @return [void]
  def remove_unfollowed_artists(all_followed_artists, previously_followed_artist_names)
    followed_artists_names = all_followed_artists.flatten.map(&:name)
    unfollowed_artists_names = previously_followed_artist_names - followed_artists_names

    return if unfollowed_artists_names.empty?

    artists_ids_to_delete = @current_user.artists.where(name: unfollowed_artists_names).pluck(:id)
    @current_user.followed_artists.where(artist_id: artists_ids_to_delete).destroy_all
  end

  # Converts an artist URI to a Spotify external link.
  #
  # @param artist_uri [String] the URI of the artist
  # @return [String] the Spotify external link for the artist
  def external_link(artist_uri)
    "spotify:#{artist_uri}"
  end
end