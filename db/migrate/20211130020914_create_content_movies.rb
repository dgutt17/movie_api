class CreateContentMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :content_movies do |t|

      t.timestamps
    end
  end
end
