# == Schema Information
#
# Table name: artists_collections
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  artist_id  :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_artists_collections_on_artist_id  (artist_id)
#  index_artists_collections_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :artists_collection do
    user { nil }
    artist { nil }
  end
end
