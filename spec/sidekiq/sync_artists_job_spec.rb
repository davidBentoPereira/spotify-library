require 'rails_helper'

RSpec.describe FetchArtistsJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user) }

    it "calls SpotifyService to fetch the followed artists of the current user" do
      followed_artist_double = instance_double(FollowedArtistsService)
      allow(FollowedArtistsService).to receive(:new).with(user).and_return(followed_artist_double)
      expect(followed_artist_double).to receive(:fetch_and_load_artists)

      FetchArtistsJob.new.perform(user.id)
    end

    context "when an exception is raised" do
      before { allow(User).to receive(:find).and_raise(ActiveRecord::RecordNotFound.new("User not found")) }

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with("Error fetching followed artists for user #{user.id}: User not found")

        FetchArtistsJob.new.perform(user.id)
      end
    end
  end
end