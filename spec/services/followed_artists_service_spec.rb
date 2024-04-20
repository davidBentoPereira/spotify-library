require "rails_helper"

RSpec.describe FollowedArtistsService do
  let(:current_user) { create(:user, :with_spotify_data) }
  let(:spotify_user) { current_user.spotify_user }

  subject(:spotify_service) { described_class.new(current_user) }

  context "#new" do
    it "initializes current_user" do
      expect(spotify_service.current_user).to eq(current_user)
    end
  end

  describe "public methods" do
    describe "#fetch_and_load_artists" do

    end
  end

  describe "private methods" do
    describe "#artists_to_create_in_db" do
      subject(:artists_to_create) { spotify_service.send(:new_artists_to_create, fetched_artists) }

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
      subject(:artists_to_follow) { spotify_service.send(:artists_to_follow, fetched_artists) }

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
  end
end