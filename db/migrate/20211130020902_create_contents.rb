class CreateContents < ActiveRecord::Migration[6.1]
  def change
    create_table :contents do |t|
      t.string :title, null: false
      t.date :release_year, null: false
      t.date :end_year
      t.integer :run_time, null: false
      t.string :imdb_id, null: false
      t.integer :content_type, null: false
      t.timestamps
    end
  end
end
