class Content < ApplicationRecord
  has_many :genres, through: :content_genres
  has_one :imdb_rating

  validates_presence_of :title, :release_year, :run_time, :imdb_id
end
