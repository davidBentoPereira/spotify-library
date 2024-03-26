require 'rails_helper'

RSpec.describe "Spotify", type: :request do
  describe "GET /show" do
    it "returns http success" do
      # TODO: Fix this spec
      post "/auth/spotify"
      expect(response).to have_http_status(:success)
    end
  end
end
