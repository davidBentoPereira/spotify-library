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

  has_many :followed_artists, dependent: :destroy # TODO: not 100% sure about that
  has_many :artists, through: :followed_artists

  validates :username, :email, presence: true
  # Username must be between 4 and 30 characters long has to contain
  # only lowercase alphabetical characters, numbers and underscores (_)
  validates :username, length: { in: 4..30 }, format: { with: /\A[a-z0-9_]{4,30}\z/ }
  validates :email, format: { with: Devise::email_regexp }


  # def auto_format_username
  # TODO : Idea 💡 : Add a feature to auto_format the username when user chooses one.
  # end

  def spotify_user
    raise MissingSpotifyDataError if spotify_data.blank?

    RSpotify::User.new(spotify_data)
  end

  # TODO: Needs to be optimized, it does 1 query for each followed_artist !!!
  def tags
    self.followed_artists.map { |fa| fa.tag_list }.flatten.uniq
  end
end
