class AddCoverUrlToArtists < ActiveRecord::Migration[7.0]
  def change
    add_column :artists, :cover_url, :string
  end
end
