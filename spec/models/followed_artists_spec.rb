# == Schema Information
#
# Table name: followed_artists
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  artist_id  :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_followed_artists_on_artist_id  (artist_id)
#  index_followed_artists_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe FollowedArtist, type: :model do
  context "with valid attributes" do
    let(:followed_artist) { build(:followed_artist) }

    it "is valid" do
      expect(followed_artist).to be_valid
    end
  end

  context "with invalid attributes" do
    it "it is not valid without a user" do
      expect(build(:followed_artist, user: nil)).not_to be_valid
    end

    it "it is not valid without an artist" do
      expect(build(:followed_artist, artist: nil)).not_to be_valid
    end
  end

  context "with associated tags" do
    let(:tag_count) { 2 }
    let(:followed_artist) { create(:followed_artist, :with_tags, tag_count: tag_count) }

    it "has associated tags" do
      expect(followed_artist.tags.count).to eq(tag_count)
      expect(followed_artist.tags.first).to be_an(ActsAsTaggableOn::Tag)
    end
  end
end
