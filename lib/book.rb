require 'net/http'
require 'open-uri'
require 'json'
require 'colorize'
require 'box_puts'
# require_relative './book_list'

class Book
    attr_reader :book_id, :summary, :price, :title, :author, :isbn, :categories

    def initialize(book_id)
        @book_id = book_id
        self.get_book_details
    end
 
    def get_book
        url = "https://www.googleapis.com/books/v1/volumes/#{self.book_id}"
        
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)
    end

    def get_book_details
        info = self.get_book
        @title = info["volumeInfo"]["title"]
        @author = info["volumeInfo"]["authors"]
        @isbn = info["volumeInfo"]["industryIdentifiers"].select{|isbn| isbn["type"] == "ISBN_10"}[0]["identifier"]
        @summary = info["volumeInfo"]["description"].gsub(/<[^>]*>/, "")

        categories_string = info["volumeInfo"]["categories"].join(" / ")
        unique_categories = categories_string.split(" / ").uniq.join(" / ")
        @categories = unique_categories.first(3)

        retail_price = info["saleInfo"]["listPrice"]
        price = retail_price["amount"]
        currency = retail_price["currencyCode"]
        @price = "$#{price} #{currency}"
    end

    def print_book_details
        BoxPuts.show(
            :align => "center",
            :title => "Book Details",
            :lines => ["Title: #{self.title}",
                "Author: #{self.author}",
                "Categories: #{self.categories}",
                "ISBN: #{self.isbn}",
                "Average Price: #{self.price}"]
        )

        puts "Would you like to save this book to your bookshelf?"
        puts "Y or N:"
        response = gets.chomp
        case response
        when "Y"
            Bookshelf.new(
                title: self.title,
                author: self.author,
                summary: self.summary,
                categories: self.categories
                price: self.price
                isbn: self.isbn
                # user_id: User self.id???
            )
        end
    end
    
    def display_book_menu 
        puts "BOOK MENU"
        puts "summary -- returns summary of book"
        puts "reviews(book_id) -- returns list of reviews"
        puts "price(book_id) -- returns the average price of this book"
        puts "buy(book_id) -- returns list of locations to buy a book"
        puts "save(book_id) -- saves book to your bookshelf"
    end
end

