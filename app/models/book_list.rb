require 'net/http'
require 'open-uri'
require 'json'
require 'colorize'
require 'tty-prompt'

class BookList
    attr_accessor :max, :search_term, :search_category
    @@collection = []

    def initialize(max:10, search_category:, search_term:)
        @search_category = search_category
        @search_term = search_term
        @max = max
    end

    def get_books
        prompt = TTY::Prompt.new
        url = "https://www.googleapis.com/books/v1/volumes?q=#{self.search_category}#{self.search_term}&maxResults=#{self.max}&filter=partial&langRestrict=en"
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        
        if response.is_a?(Net::HTTPSuccess)
            data = JSON.parse(response.body)

            if data["totalItems"] == 0
                prompt.error("Oh no! There are no results matching your search. Please try again.")
                BookstoreApp.display_menu
            elsif data.key?('items')
                unique_titles = []
                unique_books = []
                data['items'].each do |item|
                    title = item['volumeInfo']['title']
                    author = item['volumeInfo']['authors']
                    volume_info = item["volumeInfo"]
                    unless unique_titles.include?(title) || author.nil? || volume_info.nil?
                        unique_titles << title
                        unique_books << item
                    end
                end
                
            end
        else
            prompt.error("Oh no! We are having trouble retrieving your request. Please try again.")
            BookstoreApp.display_menu
        end
    end
    
    def print_books
        amount_to_return = self.max - 11
        collection = self.get_books[0..amount_to_return].reverse
        i = collection.length + 1

        collection.each do |item|
            @@collection << item
            puts "________________________".cyan
            puts "# "+"#{i -= 1}"
            puts "Title:".bold+" #{item["volumeInfo"]["title"]}"
            puts "Author:".bold+" #{item["volumeInfo"]["authors"]}"
            puts "ID:".bold+" #{item["id"]}"
            puts "Summary:".bold+" #{item["volumeInfo"]["description"]}"
        end
    end

    def self.get_book_id_by_number(num)
        index = num.to_i - 1
        @@collection.reverse[index]["id"]
    end
end
