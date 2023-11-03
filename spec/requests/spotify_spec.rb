require 'rails_helper'

RSpec.describe "Spotifies", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/spotify/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /callback" do
    it "returns http success" do
      get "/spotify/callback"
      expect(response).to have_http_status(:success)
    end
  end

end
