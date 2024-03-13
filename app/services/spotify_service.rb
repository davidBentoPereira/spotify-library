require 'open-uri'

class SpotifyService
  attr_reader :current_user, :spotify_user

  def initialize(current_user, spotify_user)
    @current_user = current_user
    @spotify_user = spotify_user
    # TODO: Should I place the initialization of spotify_user into the service ? Or Keep receiving it from the controller???
    # @spotify_user = spotify_user || RSpotify::User.new(current_user.spotify_data)
  end

  # TODO: [️️️⚡️Performance] I should make an insert_all rather than a find_or_create
  # TODO: [⚡️Performance] I should create a background job to process this work
  # TODO: [✨DB Integrity] Rollback if ther's any problem during the process
  def load_artists
    # Starts Timer
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    previously_followed_artists_by_name = @current_user.artists.pluck(:name).to_set
    all_followed_artists = []
    last_artist_id = nil
    number_of_artists_to_load = 50

    while number_of_artists_to_load == 50 # Why 50 ? Because it's the maximum number of elements per page we can get
      batch_of_followed_artists = fetch_followed_artists(last_artist_id)
      all_followed_artists << batch_of_followed_artists
      last_artist_id = batch_of_followed_artists.last&.id
      number_of_artists_to_load = batch_of_followed_artists.size

      # We make a find_or_create_by to avoid duplicates
      # TODO: [⚡️Performance Tip] I should :
      # - add an attribute spotify_id to Artist
      # - create a table index on spotify_id
      # - do the find_or_create_by on artist.spotify_id
      # Peformance will be better by searching on an Integer than on a String
      batch_of_followed_artists.each do |followed_artist|
        # Try to find the artist by name
        artist = Artist.find_or_initialize_by(name: followed_artist.name)

        # If the artist doesn't exist, create it with its external link and avatar
        if artist.new_record?
          artist.external_link = followed_artist.external_urls["spotify"]
          attach_avatar(artist, followed_artist)
          artist.save!
        end

        # Check if the user is already following the artist. If not, add it to the user's collection of artists
        unless @current_user.artists.exists?(artist.id)
          @current_user.artists << artist
        end
      end
    end

    remove_unfollowed_artists(all_followed_artists, previously_followed_artists_by_name)

    # End Timer and print it in console
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting

    Rails.logger.debug { "Fetching and loading the artists into the DB took #{elapsed.ceil}s" }
  end

  private

  def remove_unfollowed_artists(all_followed_artists, previously_followed_artists_by_name)
    followed_artists_names = all_followed_artists.flatten.map(&:name).to_set
    unfollowed_artist_names = previously_followed_artists_by_name - followed_artists_names

    return if unfollowed_artist_names.empty?

    artists_ids_to_delete = @current_user.artists.where(name: unfollowed_artist_names).pluck(:id)
    @current_user.artists_collections.where(artist_id: artists_ids_to_delete).destroy_all
  end


  # Use Spotify's API to fetch the following artists
  def fetch_followed_artists(last_artist_id)
    @spotify_user.following(type: 'artist', limit: 50, after: last_artist_id)
  end

  # Attach the avatar to the artist
  def attach_avatar(artist, spotify_artist)
    avatar_url = spotify_artist.images.last&.dig("url")
    if avatar_url
      begin
        artist.avatar.attach(io: open_avatar(avatar_url), filename: filename_avatar(artist.name))
      rescue => e
        Rails.logger.info("Error attaching avatar for artist #{artist.name}: #{e.message}")
      end
    else
      Rails.logger.info("Missing avatar URL for artist #{artist.name}")
    end
  end

  # Return a link opening the artist's page on Spotify's App
  def external_link(artist_url)
    "#{artist_url}?si=QoKxSaCaRyCyG7-dRHDVEg"
  end

  def open_avatar(url)
    URI.parse(url).open
  end

  # Return a filename for the Spotify artists' avatars
  def filename_avatar(artist_name)
    "#{artist_name.parameterize(separator: '_')}.jpg"
  end
end