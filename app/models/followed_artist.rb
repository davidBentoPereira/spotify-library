# == Schema Information
#
# Table name: followed_artists
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  artist_id  :uuid             not null
#  folder_id  :uuid
#  user_id    :uuid             not null
#
# Indexes
#
#  index_followed_artists_on_artist_id  (artist_id)
#  index_followed_artists_on_folder_id  (folder_id)
#  index_followed_artists_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (folder_id => folders.id)
#  fk_rails_...  (user_id => users.id)
#
class FollowedArtist < ApplicationRecord
  belongs_to :user, optional: false
  belongs_to :artist, optional: false
  belongs_to :folder, optional: true

  acts_as_taggable_on :tags

  validates :user_id, presence: true
  validates :artist_id, presence: true
end
