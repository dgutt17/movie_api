class Genre < ApplicationRecord
  has_many :content_genres
  has_many :contents, through: :content_genres

  validates_presence_of :name
end
