class CreateMovieGenres < ActiveRecord::Migration[6.1]
  def change
    create_table :movie_genres, id: false do |t|
      t.references :movie, index: true, foreign_key: true
      t.references :genre, index: true, foreign_key: true
    end
  end
end
