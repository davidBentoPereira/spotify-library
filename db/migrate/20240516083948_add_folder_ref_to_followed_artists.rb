class AddFolderRefToFollowedArtists < ActiveRecord::Migration[7.0]
  def change
    add_reference :followed_artists, :folder, null: true, foreign_key: true, type: :uuid
  end
end
