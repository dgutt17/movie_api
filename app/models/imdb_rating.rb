class ImdbRating < ApplicationRecord
  belongs_to :movie

  validates_presence_of :rating, :total_votes
end
