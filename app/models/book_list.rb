require 'net/http'
require 'open-uri'
require 'json'
require 'colorize'

class BookList
    attr_accessor :max, :search_term, :search_category
    @@collection = []

    def initialize(max:10, search_category:, search_term:)
        @search_category = search_category
        @search_term = search_term
        @max = max
    end

    def get_books
        begin
            url = "https://www.googleapis.com/books/v1/volumes?q=#{self.search_category}#{self.search_term}&maxResults=#{self.max}&filter=partial&orderBy=newest&langRestrict=en"
        rescue NoMethodError => e
            e.set_backtrace([])
            puts "Error Message: #{e.message}"
            # puts "Oh no! Something has gone wrong with your search. You may need to try a different search term."
            # BookstoreApp.display_menu
        else
            uri = URI.parse(url)
            response = Net::HTTP.get_response(uri)
            JSON.parse(response.body)
        end
    end
    
    def print_books
        collection = self.get_books
        i = 0
        collection["items"].each do |item|
            @@collection << item
            puts "________________________".blue
            puts "# "+"#{i += 1}"
            puts "Title:".bold+" #{item["volumeInfo"]["title"]}"
            puts "Author:".bold+" #{item["volumeInfo"]["authors"]}"
            puts "ID:".bold+" #{item["id"]}"
            puts "Summary:".bold+" #{item["volumeInfo"]["description"]}"
        end
    end

    def self.get_book_id_by_number(num)
        index = num.to_i - 1
        @@collection[index]["id"]
    end
end
