require 'open-uri'

module Imdb
  class Importer
    attr_reader :ratings_file, :content_file, :genres, :content_genres, :ratings_hash
    attr_reader :content, :ratings, :content_ids, :genre_ids, :content_genres_hash

    def initialize
      @ratings_file = gzip_reader(ENV['RATINGS_FILE_URL'])
      @content_file = gzip_reader(ENV['CONTENT_FILE_URL'])
      @genres = Set.new
      @content_genres_hash = Hash.new
      @content_genres = Array.new
      @content = Array.new
      @ratings_hash = Hash.new
      @ratings = Array.new
    end

    def run
      creating_ratings_hash
      create_content_and_genre_array
      import_content
      import_genres
      create_ratings_and_content_genres_array
      import_ratings
      import_content_genre_joins
    end

    private

    def gzip_reader(file_url)
      gzipfile = URI.open(file_url)
      Zlib::GzipReader.new(gzipfile)
    end

    def create_content_hash(content_data)
      {
        imdb_id: content_data[0],
        title: content_data[2],
        release_year: content_data[5] == '\N' ? nil : Date.parse("1-1-#{content_data[5]}"),
        end_year: content_data[6] == '\N' ? nil : Date.parse("1-1-#{content_data[6]}"),
        run_time: content_data[7] == '\N' ? nil : content_data[7].to_i
      }
    end

    def creating_ratings_hash
      puts "Printing Ratings file"
      sleep(5)
      ratings_file.each_line do |row|
        parsed_row = row.split("\t")
        if parsed_row.last.to_i >= 500
          puts "row: #{parsed_row}"
          parsed_row[parsed_row.length - 1] = parsed_row.last.split("\n").first
          ratings_hash[parsed_row.first] = parsed_row.slice(1, parsed_row.length)
        end
      end
    end

    def create_content_and_genre_array
      puts "Printing content file"
      sleep(5)
      content_file.each_line do |row|
        content_data = row.split("\t")
        puts "#{content_data}"
        ratings_data = ratings_hash[content_data.first]
        if ratings_data.present? && content_data[4].to_i == 0 && valid_content_type?(content_data[1])
          content << create_content_hash(content_data)
          setup_genre_import(content_data)
        end
      end
    end

    def setup_genre_import(content_data)
      new_genres = content_data.last.split(',').map { |genre| genre.split("\n").first }
      content_genres_hash[content_data[0]] = new_genres
      new_genres.each { |genre| genres.add({name: genre}) }
    end

    def import_content
      puts "Importing content"
      sleep(5)
      results = Content.import(content)
      @content_ids = results.ids
    end

    def import_genres
      puts "Importing Genres"
      sleep(5)
      results = Genre.import(genres.to_a)
      @genre_ids = results.ids
    end

    def imported_content
      @imported_content ||= Content.where(id: content_ids)
    end

    def import_ratings_genre_content_relation
      imported_content.each do |content| 
        ratings << ratings_hash[content.imdb_id].merge({content_id: content.id})
      end
      ImdbRating.import(ratings)
    end

    def valid_content_type?(content_type)
      content_type == 'content' || content_type == 'tvSeries' || content_type == 'tvMiniSeries'
    end

    def imported_content
      @imported_content ||= content.where(id: content_ids)
    end

    def imported_genres
      @imported_genres ||= Genre.where(id: genre_ids)
    end

    def create_ratings_and_content_genres_array
      imported_content.each do |content| 
        puts "Content: #{content.title}"
        rating_data = ratings_hash[content.imdb_id]
        rating = {content_id: content.id, rating: rating_data.first, total_votes: rating_data.last}
        ratings << rating
        content_genres_hash[content.imdb_id].each do |genre|
          genre_id = imported_genres.find {|g| g.name == genre}.id
          content_genres << {content_id: content.id, genre_id: genre_id}
        end
      end
    end

    def import_ratings
      puts "Importing Ratings"
      sleep(5)
      ImdbRating.import(ratings)
    end

    def import_content_genre_joins
      puts "Importing Content Genre Join table"
      sleep(5)
      ContentGenre.import(content_genres)
    end
  end
end