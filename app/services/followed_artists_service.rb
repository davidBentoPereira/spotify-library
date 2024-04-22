require 'json'

class FollowedArtistsService
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
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
    create_artists_in_db(new_artists)
  end

  # TODO: There may be an extra step here that could be optimized...
  def follow_new_artists(fetched_artists)
    # Get the uniq artists not already followed by the user
    new_artists_to_follow = artists_to_follow(fetched_artists)

    # TODO: extract this code into a method
    # Fetch artist IDs for newly created and existing artists
    artist_ids_to_follow = Artist.where(name: new_artists_to_follow.map(&:name)).pluck(:id)

    # TODO: extract this code into a method
    # Attach new artists to the current user
    @current_user.followed_artists.create!(artist_ids_to_follow.map { |artist_id| { artist_id: artist_id } })
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

  # TODO: Use gem active import to manage insert_all
  def create_artists_in_db(spotify_artists_to_create)
    unless spotify_artists_to_create.empty?
      Artist.insert_all(spotify_artists_to_create.map { |artist| { name: artist.name, external_link: artist.uri, cover_url: artist.images.last&.dig("url") }  }, unique_by: :name)
    end
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