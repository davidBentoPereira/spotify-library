require 'rails_helper'

RSpec.describe TagsController, type: :request do
  describe "DELETE /tags/:id" do
    let(:user) { create(:user, :with_followed_artists) }
    let(:tag) { user.tags.first }

    context "when user is logged in" do
      before { sign_in user }

      it "deletes the tag" do
        delete "/tags/#{tag.id}"

        expect(response).to redirect_to(spotify_followed_artists_path)
        expect(user.tags.exists?(name: tag.name)).to be_falsey
      end
    end

    context "when user is not logged in" do
      it "does not delete the tag" do
        delete "/tags/#{tag.id}"

        expect(response).to redirect_to(new_user_session_path)
        expect(user.tags.exists?(name: tag.name)).to be_truthy
      end
    end
  end
end
