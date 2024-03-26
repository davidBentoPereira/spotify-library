class ChangeArtistsCollectionsToFollowedArtists < ActiveRecord::Migration[7.0]
  def change
    rename_table :artists_collections, :followed_artists
  end
end
