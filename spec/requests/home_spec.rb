require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/home"
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    context "when using root_path" do
      it "returns http success" do
        get "/"
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end
    end
  end
end
