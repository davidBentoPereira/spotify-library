class CreateFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :folders, id: :uuid do |t|
      t.string :name, unique: true, null: false
      t.references :user, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
