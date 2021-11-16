require 'open-uri'

module Imdb
  class Importer
    attr_reader :ratings_file, :movies_file, :genres, :movies, :ratings

    def initialize
      @ratings_file = gzip_reader(ENV['RATINGS_FILE_URL'])
      @movies_file = gzip_reader(ENV['MOVIES_FILE_URL'])
      @genres = []
      @movies = []
      @ratings = {}
    end

    def run
      puts "Printing Ratings file"
      sleep(5)
      ratings_file.each_line do |row|
        parsed_row = row.split("\t")
        if parsed_row.last.to_i >= 500
          puts "row: #{parsed_row}"
          parsed_row[parsed_row.length - 1] = parsed_row.last.split("\n").first
          ratings[parsed_row.first] = parsed_row.slice(1, parsed_row.length)
        end
      end

      puts "Printing Movies file"
      sleep(5)
      movies_file.each_line do |row|
        movie_data = row.split("\t")
        puts "#{movie_data}"
        ratings_data = ratings[movie_data.first]
        if ratings_data.present? && movie_data[4].to_i == 0
          movies << create_movie_hash(movie_data)
          genres << create_genre_hashes(movie_data)
          genres.flatten!
        end
      end
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

    def create_genre_hashes(movie_data)
      genres = movie_data.last.split(',')
      genres.map do |genre|
        {
          imdb_id: movie_data[0],
          name: genre
        }
      end
    end
  end
end