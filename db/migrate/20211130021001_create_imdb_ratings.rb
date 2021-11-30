class CreateImdbRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :imdb_ratings do |t|
      t.belongs_to :content, index: true, foreign_key: true
      t.decimal :rating, null: false
      t.integer :total_votes, null: false
      t.timestamps
      t.timestamps
    end
  end
end
