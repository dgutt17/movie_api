class ContentGenre < ApplicationRecord
  belongs_to :content
  belongs_to :genre
end
