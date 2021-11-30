class CreateContentGenres < ActiveRecord::Migration[6.1]
  def change
    create_table :content_genres, id: false do |t|
      t.references :content, index: true, foreign_key: true
      t.references :genre, index: true, foreign_key: true
    end
  end
end
