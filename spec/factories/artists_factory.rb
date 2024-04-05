# == Schema Information
#
# Table name: artists
#
#  id            :uuid             not null, primary key
#  cover_url     :string
#  external_link :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_artists_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :artist do
    name { Faker::Music.band }
    external_link { Faker::Internet.url }
    cover_url { Faker::Internet.url }
  end
end
