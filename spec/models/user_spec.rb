# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  spotify_data           :json
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { build(:user) }

  # TODO: This test could be deleted in the futur. It exists as a proof that my user_factory is working
  it "creates a user" do
    expect { user.save! }.to change(User, :count)
  end

  describe "private methods" do
    describe "#spotify_user" do
      context "when user already has spotify_data" do
        let(:user) { create(:user, :with_spotify_data) }

        it "returns an object RSpotify::User" do
          expect(user.spotify_user).to be_a(RSpotify::User)
        end
      end

      context "when user has no spotify_data" do
        let(:user) { create(:user) }

        it "raises an error" do
          expect { user.spotify_user }.to raise_error(StandardError, /User is missing spotify_data./)
        end
      end
    end
  end
end
