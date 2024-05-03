# == Schema Information
#
# Table name: artists
#
#  id            :uuid             not null, primary key
#  cover_url     :string           not null
#  external_link :string           not null
#  genres        :text
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_artists_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe Artist, type: :model do
  describe "validations" do
    context "with valid attributes" do
      let(:artist) { build(:artist) }

      it "is valid" do
        expect(artist).to be_valid
      end
    end

    context "with invalid attributes" do
      it "it is not valid without a cover_url" do
        expect(build(:artist, cover_url: nil)).not_to be_valid
      end

      it "it is not valid without an external_link" do
        expect(build(:artist, external_link: nil)).not_to be_valid
      end

      it "it is not valid without an name" do
        expect(build(:artist, name: nil)).not_to be_valid
      end
    end
  end
end
