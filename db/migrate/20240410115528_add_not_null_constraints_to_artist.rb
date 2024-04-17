class AddNotNullConstraintsToArtist < ActiveRecord::Migration[7.0]
  def change
    change_column_null :artists, :external_link, false
    change_column_null :artists, :cover_url, false
  end
end
