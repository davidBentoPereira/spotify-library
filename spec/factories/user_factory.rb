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
    username { Faker::Internet.username.downcase }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 10, max_length: 20) }

    # TODO: To uncomment and fill in with a real example of spotify_data ?
    # trait :with_spotify do
    #   spotify_data { {} }
    # end
  end
end
