require 'open-uri'

module Imdb
  class Importer
    attr_reader :ratings_file, :movies_file, :ratings

    def initialize
      @ratings_file = gzip_reader(ENV['RATINGS_FILE_URL'])
      @movies_file = gzip_reader(ENV['MOVIES_FILE_URL'])
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

      binding.pry
      puts "Printing Movies file"
      sleep(5)
      movies_file.each_line do |line|
        puts line
      end
    end

    private

    def gzip_reader(file_url)
      gzipfile = URI.open(file_url)
      Zlib::GzipReader.new(gzipfile)
    end
  end
end