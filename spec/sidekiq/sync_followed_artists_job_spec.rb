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
  end
end