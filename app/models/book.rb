require 'net/http'
require 'open-uri'
require 'json'
require 'colorize'
require 'box_puts'
require_relative '../../config/environment.rb'
require_relative './bookstore_app'

class Book
    attr_reader :book_id, :summary, :price, :title, :author, :isbn, :categories
    def initialize(book_id)
        @book_id = book_id
        self.get_book_details
        @@book_instance = self
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
        @categories = unique_categories

        retail_price = info["saleInfo"]["listPrice"]
        price = retail_price["amount"]
        currency = retail_price["currencyCode"]
        @price = price
    end

    def print_book_details
        BoxPuts.show(
            :align => "center",
            :title => "Book Details",
            :lines => ["Title: #{self.title}",
                "Author: #{self.author}",
                "Categories: #{self.categories}",
                "ISBN: #{self.isbn}",
                "Average Price: $#{self.price}"]
        )
        
        puts "________________________".blue
        puts "Please select an action item from the list below:"
        self.class.display_book_menu
    end
    
    def self.display_book_menu 
        puts "________________________".blue
        puts "BOOK MENU"
        puts "summary -- returns summary of book"
        puts "reviews -- returns list of reviews"
        puts "buy -- returns list of locations to buy a book"
        puts "save -- saves book to your bookshelf"
        puts "exit -- back to main menu"
        puts "________________________".blue
        puts "Enter selection here:"
        response = gets.chomp
        case response
        when "summary"
            puts "Summary:".bold + "#{@@book_instance.summary}"
        when "reviews"
            puts "Will return reviews when functioning"
        when "buy"
            puts "will return where to buy"
        when "save"
            @@book_instance.save_book
        when "exit"
            BookstoreApp.display_menu
        end
        
    end

    def save_book
            Bookshelf.create(
                title: self.title,
                author: self.author,
                summary: self.summary,
                categories: self.categories,
                price: self.price,
                isbn: self.isbn,
                user_id: $current_user.id, #fix this later - global variables are bad practice
                google_book_id: book_id
            )
            puts "#{self.title} has been added to your personal bookshelf.".bold.blue
            
            self.class.display_book_menu
    end
end

# new_book = Book.new("ZMwAEAAAQBAJ")
# new_book.print_book_details