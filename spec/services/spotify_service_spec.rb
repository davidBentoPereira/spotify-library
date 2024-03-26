require "rails_helper"

RSpec.describe SpotifyService do
  let(:current_user) { create(:user, :with_spotify_data) }
  let(:spotify_user) { current_user.spotify_user }
  let(:following_mock) {
    [
      RSpotify::Artist.new(
          followers: {
            href: nil,
            total: 115414
          },
          genres: [
            "french pop",
            "nouvelle chanson francaise"
          ],
          images: [
            {
              height: 640,
              url: "https://i.scdn.co/image/ab6761610000e5eb0c9b46616573eacd85a357bd",
              width: 640
            },
            {
              height: 320,
              url: "https://i.scdn.co/image/ab676161000051740c9b46616573eacd85a357bd",
              width: 320
            },
            {
              height: 160,
              url: "https://i.scdn.co/image/ab6761610000f1780c9b46616573eacd85a357bd",
              width: 160
            }
          ],
          name: "Suzane",
          popularity: 44,
          top_tracks: {},
          external_urls: {
            spotify: "https://open.spotify.com/artist/00CTomLgA78xvwEwL0woWx"
          },
          href: "https://api.spotify.com/v1/artists/00CTomLgA78xvwEwL0woWx",
          id: "00CTomLgA78xvwEwL0woWx",
          type: "artist",
          uri: "spotify:artist:00CTomLgA78xvwEwL0woWx"
      )
    ]
  }

  subject(:spotify_service) { SpotifyService.new(current_user) }

  context "#new" do
    it "initializes current_user" do
      expect(spotify_service.current_user).to eq(current_user)
    end
  end

  context "#load_artists" do
    subject(:fetch_and_load_followed_artists) { spotify_service.fetch_and_load_followed_artists }

    context "when there is a new followed artist" do
      before do
        allow_any_instance_of(RSpotify::User).to receive(:following).and_return(following_mock)
      end

      it "adds a new artist into the database" do
      #   expect(fetch_and_load_followed_artists).to change(Artist, :count).by(1)
      end

      # it "adds the artist to the user's followed artists"
    end

    context "when a spotify artist has been unfollowed" do
      it "removes the link from the user's followed artists"
      it "keeps the artist into the database"
    end
  end
end