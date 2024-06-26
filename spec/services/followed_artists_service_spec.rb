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
      let(:artist1) { build(:artist, name: "Artist 1") }
      let(:artist2) { build(:artist, name: "Artist 2") }
      let(:fetched_artists) { [artist1, artist2] }

      subject(:fetch_and_load_artists) { service.fetch_and_load_artists }

      before do
        allow_any_instance_of(SpotifyService).to receive(:artists).and_return(fetched_artists)
        allow_any_instance_of(FollowedArtistsService).to receive(:create_new_artists).with(fetched_artists)
        allow_any_instance_of(FollowedArtistsService).to receive(:follow_new_artists).with(fetched_artists)
        allow_any_instance_of(FollowedArtistsService).to receive(:remove_unfollowed_artists).with(fetched_artists)
      end

      it "fetches all followed artists" do
        expect_any_instance_of(SpotifyService).to receive(:artists)
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
        let(:artists) { build_list(:artist, 2) }

        it "creates new records in the artists table" do
          expect { create_artists }.to change(Artist, :count).by(2)
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

    describe "#fetch_artist_ids_to_follow" do
      subject(:fetch_artist_ids_to_follow) { service.send(:fetch_artist_ids_to_follow, new_artists_to_follow) }

      context "when there are new artists to follow" do
        let!(:artist1) { create(:artist, name: "Artist 1") }
        let!(:artist2) { create(:artist, name: "Artist 2") }
        let!(:artist3) { create(:artist, name: "Artist 3") }

        let(:new_artists_to_follow) { [artist1, artist2] }

        it "returns an array of artist IDs" do
          expect(fetch_artist_ids_to_follow).to contain_exactly(artist1.id, artist2.id)
        end
      end

      context "when there are no new artists to follow" do
        let!(:existing_artists) { create_list(:artist, 3) }
        let(:new_artists_to_follow) { [] }

        it "returns an empty array" do
          expect(fetch_artist_ids_to_follow).to be_empty
        end
      end
    end

    describe "#attach_new_followed_artists" do
      subject(:attach_new_followed_artists) { service.send(:attach_new_followed_artists, artist_ids_to_follow) }

      context "when there are new artists to follow" do
        let!(:artist1) { create(:artist) }
        let!(:artist2) { create(:artist) }
        let!(:artist3) { create(:artist) }

        let(:artist_ids_to_follow) { [artist1.id, artist2.id] }

        it "associates the new artists with the current user" do
          expect { attach_new_followed_artists }.to change(current_user.followed_artists, :count).by(2)
        end
      end

      context "when there are no new artists to follow" do
        let(:artist_ids_to_follow) { [] }

        it "does not associate any new artists with the current user" do
          expect { attach_new_followed_artists }.not_to change(current_user.followed_artists, :count)
        end
      end
    end

    describe "#remove_unfollowed_artists" do
      let!(:current_user) { create(:user, :with_followed_artists, followed_artist_count: 2) }

      subject(:remove_unfollowed_artists) { service.send(:remove_unfollowed_artists, fetched_artists) }

      context "when some artists were unfollowed" do
        let(:fetched_artists) { [build(:artist, name: current_user.artists.first&.name)] }

        it "unfollows them" do
          expect(current_user.artists.count).to eq(2)
          remove_unfollowed_artists
          expect(current_user.artists).to match_array(current_user.artists.first)
        end
      end

      context "when no artists were unfollowed" do
        let(:existing_artists_names) { current_user.artists.pluck(:name) }
        let(:fetched_artists) { [
          build(:artist, name: current_user.artists.first&.name),
          build(:artist, name: current_user.artists.last&.name),
          build(:artist),
        ] }

        it "doesn't unfollow them" do
          remove_unfollowed_artists
          expect(current_user.artists.where(name: existing_artists_names).count).to eq(2)
        end
      end
    end
    describe "#remove_unfollowed_artists" do
      let!(:current_user) { create(:user, :with_followed_artists, followed_artist_count: 2) }

      subject(:remove_unfollowed_artists) { service.send(:remove_unfollowed_artists, fetched_artists) }

      context "when some artists were unfollowed" do
        let(:fetched_artists) { [build(:artist, name: current_user.artists.first&.name)] }

        it "unfollows them" do
          expect(current_user.artists.count).to eq(2)
          remove_unfollowed_artists
          expect(current_user.artists).to match_array(current_user.artists.first)
        end
      end

      context "when no artists were unfollowed" do
        let(:existing_artists_names) { current_user.artists.pluck(:name) }
        let(:fetched_artists) { [
          build(:artist, name: current_user.artists.first&.name),
          build(:artist, name: current_user.artists.last&.name),
          build(:artist),
        ] }

        it "doesn't unfollow them" do
          remove_unfollowed_artists
          expect(current_user.artists.where(name: existing_artists_names).count).to eq(2)
        end
      end
    end
  end
end