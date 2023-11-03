class CreateArtistsCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :artists_collections, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :artist, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
