class AddGenresToArtists < ActiveRecord::Migration[7.0]
  def change
    add_column :artists, :genres, :text
  end
end
