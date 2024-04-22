require 'json'

class FollowedArtistsService
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  # Fetches artists from Spotify and loads them into the database, associating them with the current user.
  #
  # @return [void]
  def fetch_and_load_artists
    ActiveRecord::Base.transaction do
      fetched_artists = SpotifyService.new(@current_user.spotify_user).fetch_all_followed_artists
      create_new_artists(fetched_artists)
      follow_new_artists(fetched_artists)
      remove_unfollowed_artists(fetched_artists)
    end
  end

  private

  # Create new artists in the database.
  #
  # This method takes an array of fetched artists and filters out the ones that are not already existing
  # in the database. It then inserts the new artists into the database.
  #
  # @param fetched_artists [Array<Artist>] An array of artists fetched from an external source.
  # @return [void]
  def create_new_artists(fetched_artists)
    new_artists = new_artists_to_create(fetched_artists)
    create_artists(new_artists)
  end

  def follow_new_artists(fetched_artists)
    new_artists_to_follow = artists_to_follow(fetched_artists)
    artist_ids_to_follow = fetch_artist_ids_to_follow(new_artists_to_follow)
    attach_new_followed_artists(artist_ids_to_follow)
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
  def new_artists_to_create(fetched_artists)
    existing_artist_names = Artist.where(name: fetched_artists.map(&:name)).pluck(:name)
    fetched_artists.reject { |followed_artist| existing_artist_names.include?(followed_artist.name) }
  end

  # Insert artists into the database.
  #
  # This method takes an array of artists and inserts them into the database. It creates new records in the artists table
  # with the provided information for each artist. If the provided array is empty, no database operation is performed.
  #
  # @param artists [Array<Hash>] An array containing hashes with information about the artists to be created.
  #   Each hash should contain the following keys:
  #   - :name (String): The name of the artist.
  #   - :external_link (String): The external link to the artist, typically a URI.
  #   - :cover_url (String): The URL of the artist's cover image.
  # @return [void]
  # TODO: Use gem active import to manage insert_all
  def create_artists(artists)
    return if artists.empty?

    Artist.insert_all(artists.map { |a| { name: a.name, external_link: a.uri, cover_url: a.images.last&.dig("url") }  }, unique_by: :name)
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


  # Fetches the IDs of artists to be followed by the current user.
  #
  # This method takes an array of new artists to be followed by the user and retrieves their corresponding
  # IDs from the database. It returns an array containing the IDs of the artists to be followed.
  #
  # @param new_artists_to_follow [Array<Artist>] An array of new artists to be followed by the user.
  # @return [Array<Integer>] An array containing the IDs of the artists to be followed.
  def fetch_artist_ids_to_follow(new_artists_to_follow)
    Artist.where(name: new_artists_to_follow.map(&:name)).pluck(:id)
  end

  # Attach new followed artists to the current user.
  #
  # This method takes an array of artist IDs to be followed by the user and associates them with the current user
  # by creating corresponding records in the followed_artists join table. Each record contains the ID of the artist
  # to be followed and the ID of the current user.
  #
  # @param artist_ids_to_follow [Array<Integer>] An array containing the IDs of the artists to be followed.
  # @return [void]
  def attach_new_followed_artists(artist_ids_to_follow)
    @current_user.followed_artists.create!(artist_ids_to_follow.map { |artist_id| { artist_id: artist_id } })
  end

  # Removes unfollowed artists from the current user's followed artists.
  #
  # @param fetched_artists [Array<Artist>] the list of all followed artists fetched from Spotify
  # @return [void]
  def remove_unfollowed_artists(fetched_artists)
    prev_followed_artist_names = @current_user.artists.pluck(:name)
    new_followed_artists_names = fetched_artists.map(&:name)
    artists_names_to_unfollow = prev_followed_artist_names - new_followed_artists_names

    return if artists_names_to_unfollow.empty?

    artists_ids_to_delete = @current_user.artists.where(name: artists_names_to_unfollow).pluck(:id)
    @current_user.followed_artists.where(artist_id: artists_ids_to_delete).destroy_all
  end
end