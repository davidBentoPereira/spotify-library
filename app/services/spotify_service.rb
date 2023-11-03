require 'open-uri'

class SpotifyService
  def initialize(spotify_user)
    @spotify_user = spotify_user
  end

  # TODO: [Performance] I should create a background job to process this work
  # TODO: [Performance] I should make an insert_all rather than .create
  #
  # TODO: [] Manage when an artist isn't followed anymore
  def load_artists
    number_of_artists_to_load, last_artist_id = 50, nil

    while number_of_artists_to_load == 50
      followed_artists = @spotify_user.following(type: 'artist', limit: 50, after: last_artist_id)
      last_artist_id = followed_artists.last.id
      number_of_artists_to_load = followed_artists.size

      # Add the artists to the database
      followed_artists.each do |artist|
        # We make a find_or_create_by to avoid duplicates
        # TODO: [Performance Tip] I should :
        # - add an attribute spotify_id to Artist
        # - create a table index on spotify_id
        # - do the find_or_create_by on artist.spotify_id
        # Peformance will be better by searching on an Integer than on a String
        new_artist = Artist.find_or_create_by(name: artist.name) do |a|
          a.name = artist.name
          a.external_link = external_link(artist.external_urls["spotify"])
        end

        # Attach the avatar to the artist
        begin
          new_artist.avatar.attach(io: open_avatar(artist.images.last["url"]), filename: filename_avatar(artist.name))
        rescue => e
          Rails.logger.info("Missing Cover for artist #{artist.name} !")
        end
      end
    end
  end

  private

  # Return a link opeing the artist's page on Spotify's App
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