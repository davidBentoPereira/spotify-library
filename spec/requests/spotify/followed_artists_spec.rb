require 'rails_helper'

RSpec.describe Spotify::FollowedArtistsController, type: :request do
  describe "GET /index" do
    context "when user is authenticated" do
      let(:user) { create(:user, :with_spotify_data, :with_followed_artists, followed_artist_count: 2) }

      before { sign_in(user) }

      it "renders the index page" do
        get spotify_followed_artists_path
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end

      it "displays user related data" do
        get spotify_followed_artists_path
        expect(assigns(:total_count)).to eq(2)
        expect(assigns(:followed_artists)).to match_array(user.followed_artists)
        expect(assigns(:total_pages)).to eq(1)
        expect(assigns(:tags)).to eq(user.tags)
      end
    end

    # context "when user is not authenticated" do
    #   let(:user) { create(:user, :with_spotify_data, :with_followed_artists, followed_artist_count: 2) }
    #
    #   it "renders the index page" do
    #     get spotify_followed_artists_path
    #     expect(response).to have_http_status(:found)
    #     expect(response).to render_template(:index)
    #   end
    #
    #   it "doesn't displays user related data" do
    #     get spotify_followed_artists_path
    #     expect(assigns(:total_count)).to eq(0)
    #     # expect(assigns(:followed_artists)).to match_array([])
    #     # expect(assigns(:total_pages)).to eq(1)
    #     # expect(assigns(:tags)).to eq(user.tags)
    #   end
    # end
  end
end
