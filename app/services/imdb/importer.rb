require 'open-uri'

module Imdb
  class Importer
    attr_reader :ratings_file, :movies_file, :genres, :movie_genres, :ratings_hash
    attr_reader :movies, :ratings, :movie_ids, :genre_ids, :movie_genres_hash

    def initialize
      @ratings_file = gzip_reader(ENV['RATINGS_FILE_URL'])
      @movies_file = gzip_reader(ENV['MOVIES_FILE_URL'])
      @genres = Set.new
      @movie_genres_hash = Hash.new
      @movie_genres = Array.new
      @movies = Array.new
      @ratings_hash = Hash.new
      @ratings = Array.new
    end

    def run
      creating_ratings_hash
      create_movies_and_genre_array
      import_movies
      import_genres
      create_ratings_and_movie_genres_array
      import_ratings
      import_movie_genre_joins
    end

    private

    def gzip_reader(file_url)
      gzipfile = URI.open(file_url)
      Zlib::GzipReader.new(gzipfile)
    end

    def create_movie_hash(movie_data)
      {
        imdb_id: movie_data[0],
        title: movie_data[2],
        release_year: movie_data[5] == '\N' ? nil : Date.parse("1-1-#{movie_data[5]}"),
        end_year: movie_data[6] == '\N' ? nil : Date.parse("1-1-#{movie_data[6]}"),
        run_time: movie_data[7] == '\N' ? nil : movie_data[7].to_i
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

    def create_movies_and_genre_array
      puts "Printing Movies file"
      sleep(5)
      movies_file.each_line do |row|
        movie_data = row.split("\t")
        puts "#{movie_data}"
        ratings_data = ratings_hash[movie_data.first]
        if ratings_data.present? && movie_data[4].to_i == 0 && valid_content_type?(movie_data[1])
          movies << create_movie_hash(movie_data)
          setup_genre_import(movie_data)
        end
      end
    end

    def setup_genre_import(movie_data)
      new_genres = movie_data.last.split(',').map { |genre| genre.split("\n").first }
      movie_genres_hash[movie_data[0]] = new_genres
      new_genres.each { |genre| genres.add({name: genre}) }
    end

    def import_movies
      puts "Importing Movies"
      sleep(5)
      results = Movie.import(movies)
      @movie_ids = results.ids
    end

    def import_genres
      puts "Importing Genres"
      sleep(5)
      results = Genre.import(genres.to_a)
      @genre_ids = results.ids
    end

    def imported_movies
      @imported_movies ||= Movie.where(id: movie_ids)
    end

    def import_ratings_genre_movie_relation
      imported_movies.each do |movie| 
        ratings << ratings_hash[movie.imdb_id].merge({movie_id: movie.id})
      end
      ImdbRating.import(ratings)
    end

    def valid_content_type?(content_type)
      content_type == 'movie' || content_type == 'tvSeries' || content_type == 'tvMiniSeries'
    end

    def imported_movies
      @imported_movies ||= Movie.where(id: movie_ids)
    end

    def imported_genres
      @imported_genres ||= Genre.where(id: genre_ids)
    end

    def create_ratings_and_movie_genres_array
      imported_movies.each do |movie| 
        puts "Content: #{movie.title}"
        rating_data = ratings_hash[movie.imdb_id]
        rating = {movie_id: movie.id, rating: rating_data.first, total_votes: rating_data.last}
        ratings << rating
        movie_genres_hash[movie.imdb_id].each do |genre|
          genre_id = imported_genres.find {|g| g.name == genre}.id
          movie_genres << {movie_id: movie.id, genre_id: genre_id}
        end
      end
    end

    def import_ratings
      puts "Importing Ratings"
      sleep(5)
      ImdbRating.import(ratings)
    end

    def import_movie_genre_joins
      puts "Importing Movie Genre Join table"
      sleep(5)
      MovieGenre.import(movie_genres)
    end
  end
end