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
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  validates :username, :email, presence: true
  # Username must be between 4 and 30 characters long has to contain
  # only lowercase alphabetical characters, numbers and underscores (_)
  validates :username, length: { in: 4..30 }, format: { with: /\A[a-z0-9_]{4,30}\z/ }
  validates :email, format: { with: Devise::email_regexp }

  # TODO: Add callback to auto format username + unit tests
end
