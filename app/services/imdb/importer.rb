require 'open-uri'

module Imdb
  class Importer
    attr_reader :ratings_file, :movies_file

    def initialize
      @ratings_file = gzip_reader(ENV['RATINGS_FILE_URL'])
      @movies_file = gzip_reader(ENV['MOVIES_FILE_URL'])
    end

    def run
      puts "Printing Ratings file"
      sleep(5)
      ratings_file.each_line do |line|
        puts line
      end

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