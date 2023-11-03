class CreateArtists < ActiveRecord::Migration[7.0]
  def change
    create_table :artists, id: :uuid do |t|
      t.string :name
      t.string :external_link

      t.timestamps
    end
  end
end
