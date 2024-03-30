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
class Artist < ApplicationRecord
  has_one_attached :avatar

  has_many :followed_artists, dependent: :nullify # TODO: not 100% sure about that
  has_many :users, through: :followed_artists

  validates :name, :external_link, presence: true
end
