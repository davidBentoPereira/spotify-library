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
  describe "validations" do
    context "with valid attributes" do
      let(:user) { build(:user) }

      it "is valid" do
        expect(user).to be_valid
      end
    end

    context "with invalid attributes" do
      it "it is not valid without a username" do
        expect(build(:user, username: nil)).not_to be_valid
      end

      it "it is not valid without an email" do
        expect(build(:user, email: nil)).not_to be_valid
      end
    end
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

    describe "#tags" do
      let(:user) { create(:user, :with_followed_artists, followed_artist_count: 1) }

      it "lists all the tags created by the user" do
        expect(user.tags).not_to be_empty
        expect(user.tags.count).to eq(2)
      end
    end

    describe "#delete_tags" do
      let(:user) { create(:user, :with_followed_artists, followed_artist_count: 2) }

      context "when deleting one tag" do
        context "when user has tags" do
          it "removes the tag" do
            tags_count_before_delete = user.tags.count
            user.delete_tags(user.tags.first.name)
            expect(user.tags.count).to eq(tags_count_before_delete - 1)
          end
        end

        context "when user has no tags" do
          let(:user) { create(:user) }
          let(:tag_to_delete) { user.tags.first }

          it "does nothing" do
            expect(ActsAsTaggableOn::Tag.count).to eq(0)
            user.delete_tags("rock")
            expect(user.tags.count).to eq(0)
          end
        end
      end

      context "when deleting several tags" do
        let(:user) { create(:user, :with_followed_artists, followed_artist_count: 2) }
        let(:tags_to_delete) {  [user.tags.first.name, user.tags.last.name] }

        it "deletes the selected tags" do
          tags_count_before_delete = user.tags.count

          user.delete_tags(*tags_to_delete)

          expect(user.tags.count).to eq(tags_count_before_delete - 2)
          tags_to_delete.each do |tag_name|
            expect(user.tags).not_to include(tag_name)
          end
        end

        it "returns the list of user tags without the deleted ones" do
          remaining_tags = user.tags.reject { |tag| tags_to_delete.include?(tag.name) }

          user.delete_tags(*tags_to_delete)
          expect(user.tags).to match_array(remaining_tags)
        end
      end
    end
  end
end
