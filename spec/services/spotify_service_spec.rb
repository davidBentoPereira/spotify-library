RSpec.describe SpotifyService do
  context "#load_artists" do
    # let(:spotify_data) {
    #
    # }

    # Get Spotify's user data
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    # Save User's spotify data
    current_user.update(spotify_data: spotify_user.as_json)
    # Save artists


    subject(:load_artists) { SpotifyService.new(SpotifyService.new(current_user, spotify_user).load_artists) }

    context "when there is a new followed artist" do
      it "adds a new artist into the database" do

      end


      it "adds the artist to the user's collection of artists"
    end

    context "when a spotify artist has been unfollowed" do
      it "removes the link from the user's collection of artists"

      it "keeps the artist into the database"
    end
  end
end