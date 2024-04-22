require "rails_helper"

RSpec.describe FollowedArtistsService do
  let(:current_user) { create(:user, :with_spotify_data) }
  let(:spotify_user) { current_user.spotify_user }

  subject(:service) { described_class.new(current_user) }

  context "#new" do
    it "initializes current_user" do
      expect(service.current_user).to eq(current_user)
    end
  end

  describe "public methods" do
    describe "#fetch_and_load_artists" do
      let(:fetched_artists) { [
        double("artist", name: "Artist 1", uri: "spotify:artist:1"),
        double("artist", name: "Artist 2", uri: "spotify:artist:1"),
      ] }

      subject(:fetch_and_load_artists) { service.fetch_and_load_artists }

      before do
        allow_any_instance_of(SpotifyService).to receive(:fetch_all_followed_artists).and_return(fetched_artists)
        allow_any_instance_of(FollowedArtistsService).to receive(:create_new_artists).with(fetched_artists)
        allow_any_instance_of(FollowedArtistsService).to receive(:follow_new_artists).with(fetched_artists)
        allow_any_instance_of(FollowedArtistsService).to receive(:remove_unfollowed_artists).with(fetched_artists)
      end

      it "fetches all followed artists" do
        expect_any_instance_of(SpotifyService).to receive(:fetch_all_followed_artists)
        fetch_and_load_artists
      end

      it "creates new artists" do
        expect(service).to receive(:create_new_artists).with(fetched_artists)
        fetch_and_load_artists
      end

      it "follows new artists" do
        expect(service).to receive(:follow_new_artists).with(fetched_artists)
        fetch_and_load_artists
      end

      it "removes unfollowed artists" do
        expect(service).to receive(:remove_unfollowed_artists).with(fetched_artists)
        fetch_and_load_artists
      end
    end
  end

  describe "private methods" do
    describe "#new_artists_to_create" do
      subject(:artists_to_create) { service.send(:new_artists_to_create, fetched_artists) }

      context "when there are artists to create" do
        let!(:existing_artist) { create(:artist, name: "Existing Artist 1")}
        let(:fetched_artists) { [build(:artist, name: "Existing Artist 1"), build(:artist, name: "Existing Artist 2")] }

        it "returns only artists not already in the database" do
          expect(artists_to_create).to match_array(fetched_artists.last)
        end
      end

      context "when all fetched artists already exists in the database" do
        let!(:existing_artists) { [create(:artist, name: "Existing Artist 1"), create(:artist, name: "Existing Artist 2")]}
        let(:fetched_artists) { [build(:artist, name: "Existing Artist 1"), build(:artist, name: "Existing Artist 2")] }

        it  "returns an empty array" do
          expect(artists_to_create).to be_empty
        end
      end
    end

    describe "#create_artists" do
      subject(:create_artists) { service.send(:create_artists, artists) }

      context "when artists array is empty" do
        let(:artists) { [] }

        it "does not perform any database operation" do
          expect { create_artists }.not_to change(Artist, :count)
        end
      end

      context "when artists array is not empty" do
        let(:artists) do
          [
            double("Artist", name: "Artist 1", uri: "spotify:artist1", images: [{ "url" => "http://example.com/artist1.jpg" }]),
            double("Artist", name: "Artist 2", uri: "spotify:artist2", images: [{ "url" => "http://example.com/artist2.jpg" }])
          ]
        end

        it "creates new records in the artists table" do
          expect { create_artists }.to change(Artist, :count).by(2)
        end

        it "creates records with correct attributes" do
          create_artists
          artist1 = Artist.find_by(name: "Artist 1")
          artist2 = Artist.find_by(name: "Artist 2")

          expect(artist1).to have_attributes(name: "Artist 1", external_link: "spotify:artist1", cover_url: "http://example.com/artist1.jpg")
          expect(artist2).to have_attributes(name: "Artist 2", external_link: "spotify:artist2", cover_url: "http://example.com/artist2.jpg")
        end
      end
    end

    describe "#artists_to_follow" do
      subject(:artists_to_follow) { service.send(:artists_to_follow, fetched_artists) }

      context "when there are artists to follow" do
        let!(:followed_artist) { create(:artist, name: "Followed Artist 1") }
        let(:fetched_artists) { [build(:artist, name: "Followed Artist 1"), build(:artist, name: "Followed Artist 2")] }

        before { current_user.artists << followed_artist }

        it "follows only artists not already followed by the current user" do
          expect(artists_to_follow).to match_array(fetched_artists.last)
        end
      end

      context "when all fetched artists are already followed by the current user" do
        let!(:followed_artists) { [create(:artist, name: "Followed Artist 1"), create(:artist, name: "Followed Artist 2")] }
        let(:fetched_artists) { [build(:artist, name: "Followed Artist 1"), build(:artist, name: "Followed Artist 2")] }

        before { current_user.artists << followed_artists }

        it "returns an empty array" do
          expect(artists_to_follow).to be_empty
        end
      end
    end

    # TODO: Write specs
    describe "#fetch_artist_ids_to_follow" do

    end

    # TODO: Write specs
    describe "#attach_new_followed_artists" do

    end

    describe "#remove_unfollowed_artists" do
      let!(:current_user) { create(:user, :with_spotify_data, :with_followed_artists, followed_artist_count: 2) }

      subject(:remove_unfollowed_artists) { service.send(:remove_unfollowed_artists, fetched_artists) }

      context "when some artists were unfollowed" do
        let(:fetched_artists) { [double("artist", name: current_user.artists.first&.name)] }

        it "unfollows them" do
          remove_unfollowed_artists
          expect(current_user.artists).to match_array(current_user.artists.first)
        end
      end

      context "when no artists were unfollowed" do
        let(:existing_artists_names) { current_user.artists.pluck(:name) }
        let(:fetched_artists) { [
          double("artist", name: current_user.artists.first&.name),
          double("artist", name: current_user.artists.last&.name),
          double("artist", name: "New Followed Artist"),
        ] }

        it "doesn't unfollow them" do
          remove_unfollowed_artists
          expect(current_user.artists.where(name: existing_artists_names).count).to eq(2)
        end
      end
    end
  end
end