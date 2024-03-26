require 'rails_helper'

RSpec.describe SyncFollowedArtistsJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user) }

    it "calls SpotifyService to sync the followed artists of the current user" do
      spotify_service_double = instance_double(SpotifyService)
      allow(SpotifyService).to receive(:new).with(user).and_return(spotify_service_double)
      expect(spotify_service_double).to receive(:load_artists)

      SyncFollowedArtistsJob.new.perform(user.id)
    end

    context "when an exception is raised" do
      before { allow(User).to receive(:find).and_raise(StandardError.new("User not found")) }

      it "logs an error" do
        expect(Rails.logger).to receive(:error).with("Error syncing followed artists for user #{user.id}: User not found")

        SyncFollowedArtistsJob.new.perform(user.id)
      end
    end
  end
end