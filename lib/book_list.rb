require 'net/http'
require 'open-uri'
require 'json'
require 'colorize'

class BookList
    attr_accessor :max, :search_term, :search_category

    def initialize(max=10)
        @search_category = search_category
        @search_term = search_term
        @max = max
    end

    def get_books
        url = "https://www.googleapis.com/books/v1/volumes?q=#{self.search_category}#{self.search_term}&maxResults=#{self.max}"
    
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)
    end
    
    def print_books
        collection = self.get_books
        collection["items"].each do |items|
            puts "________________________".blue
            puts "Title:".bold+" #{items["volumeInfo"]["title"]}"
            puts "Author:".bold+" #{items["volumeInfo"]["authors"]}"
            puts "ID:".bold+" #{items["id"]}"
            puts "Summary:".bold+" #{items["volumeInfo"]["description"]}"
        end
    end

    # def get_books_by_author(author)
    #     self.print_books("inauthor:#{author}")
    # end

    # def get_books_by_category(category)
    #     self.print_books("subject:#{category}")
    # end

    # def get_books_by_title(title)
    #     self.print_books("intitle:#{title}")
    # end

    # def add_filter(filter)
    #     if filter == "download"
    #         get_books("download=epub")
    #     end
    # end

    # def filter_downloadable_books
    #     #Filter by: partial-parts of the text are previewable
    #     #full - all the text is viewable
    #     #free-ebooks - free Google eBooks
    #     #paid-ebooks - Google eBooks with a price
    #     #ebooks - Google eBooks paid or free. Does not return limited preview or not for sale items, or magazines
    #     get_books("filter=#{filter}")
    # end
end
