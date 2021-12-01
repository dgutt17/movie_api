require 'open-uri'
module RottenTomatoes
  class Importer
    ROTTEN_TOMATOES_URL = 'https://www.rottentomatoes.com/m/'
    attr_reader :content_array, :ratings_to_import
    def initialize
      @start_time = Time.now
      @content_array = Content.all
      @ratings_to_import = Array.new
    end

    def run
      content_array.each do |content|
        puts "Show: #{content.title}"
        puts "Count: #{ratings_to_import.length}"
        ratings_hash = {}
        doc = html_document(content)
        score_board = doc.css('score-board').first
        release_date = doc.css('.panel-body.content_body').css('ul.content-meta').css('time').first.children.text
        ratings_hash.tap do |h|
          h[:audience_score] = score_board.attributes['audiencescore'].value
          h[:audience_total] = score_board.children[7].children.first.text.tr('^0-9', '')
          h[:critics_score] = score_board.attributes['tomatometerscore'].value
          h[:critics_total] = score_board.children[5].children.first.text.tr('^0-9', '')
          h[:release_date] = release_date
        end

        ratings_to_import << ratings_hash
      rescue => e
        puts "error: #{e.message}"
      end

      puts "Total: #{ratings_to_import.count}"
      puts "Time to complete: #{Time.now - @start_time}"
    end
    
    private 
    
    def html_document(content)
      Nokogiri::HTML(URI.open(ROTTEN_TOMATOES_URL + content_title_parsed(content)))
    end

    def content_title_parsed(content)
      content.title.split(' ').join('_').underscore
    end
  end
end