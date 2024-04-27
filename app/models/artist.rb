# == Schema Information
#
# Table name: artists
#
#  id            :uuid             not null, primary key
#  cover_url     :string           not null
#  external_link :string           not null
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

  serialize :genres, Array

  validates :name, :external_link, :cover_url, presence: true
end
