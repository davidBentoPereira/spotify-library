# == Schema Information
#
# Table name: artists
#
#  id            :uuid             not null, primary key
#  external_link :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Artist < ApplicationRecord
  has_one_attached :avatar

  validates :name, :external_link, presence: true
end
