class Movie < ApplicationRecord
  has_many :movie_genres
  has_many :genres, through: :movie_genres
  has_one :imdb_rating

  validates_presence_of :title, :release_year, :run_time, :imdb_id
end
