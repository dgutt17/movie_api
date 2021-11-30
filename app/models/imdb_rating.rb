class ImdbRating < ApplicationRecord
  belongs_to :content

  validates_presence_of :rating, :total_votes
end
