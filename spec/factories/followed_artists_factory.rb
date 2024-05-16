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
FactoryBot.define do
  factory :followed_artist do
    user { create(:user) }
    artist { create(:artist) }

    transient do
      tag_count { 2 }  # Define the number of random tags to generate
    end

    trait :with_tags do
      after(:create) do |followed_artist, evaluator|
        # Make sure we always have the right count of uniq tags
        tags = []
        while tags.length < evaluator.tag_count
          tag = Faker::Music.genre
          tags << tag unless tags.include?(tag)
        end

        followed_artist.user.tag(followed_artist, :with => tags, :on => :tags)
        followed_artist.save
      end
    end

    trait :with_folder do
      folder { create(:folder, user: user) }
    end
  end
end