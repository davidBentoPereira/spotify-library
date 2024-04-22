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
    # TODO: Write specs
    describe "#fetch_and_load_artists"
  end

  describe "private methods" do
    describe "#artists_to_create_in_db" do
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

    describe "#remove_unfollowed_artists" do
      let!(:current_user) { create(:user, :with_spotify_data, :with_followed_artists, followed_artist_count: 2) }

      subject(:remove_unfollowed_artists) { service.send(:remove_unfollowed_artists, fetched_artists) }

      context "when some artists were unfollowed" do
        let(:fetched_artists) { [double("artist", name: current_user.artists.first.name)] }

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