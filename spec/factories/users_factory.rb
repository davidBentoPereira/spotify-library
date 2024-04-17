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
FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 4..30, separators: %w(_)) }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 10, max_length: 20) }

    transient do
      followed_artist_count { 2 }
    end

    trait :with_spotify_data do
      spotify_data do
        {
          birthdate: "1990-05-15",
          country: "US",
          display_name: "john_doe",
          email: "john.doe@example.com",
          followers: {
            href: nil,
            total: 1000
          },
          images: [
            {
              url: "https://example.com/image1.jpg",
              height: 100,
              width: 100
            },
            {
              url: "https://example.com/image2.jpg",
              height: 200,
              width: 200
            }
          ],
          product: "free",
          external_urls: {
            spotify: "https://open.spotify.com/user/john_doe"
          },
          href: "https://api.spotify.com/v1/users/john_doe",
          id: "john_doe",
          type: "user",
          uri: "spotify:user:john_doe",
          credentials: {
            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
            refresh_token: "m5VgoYCGNBr8SKys",
            expires_at: 1910760210,
            expires: false
          }
        }
      end
    end

    trait :with_followed_artists do
      after(:create) do |user, evaluator|
        create_list(:followed_artist, evaluator.followed_artist_count, :with_tags, user: user)
      end
    end
  end
end
