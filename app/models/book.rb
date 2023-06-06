require 'net/http'
require 'open-uri'
require 'json'
require 'colorize'
require 'box_puts'
require_relative '../../config/environment.rb'
require_relative './bookstore_app'
require 'tty-prompt'

class Book
    attr_reader :book_id, :summary, :price, :title, :author, :isbn, :categories, :info_link
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

        @info_link = info["volumeInfo"]["infoLink"]
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
        
        puts "________________________".cyan
        puts ""
        self.class.display_book_menu
    end
    
    def self.display_book_menu 
        prompt = TTY::Prompt.new(active_color: :cyan)
        choices = [
            {name: "Summary -- Returns summary of book", value: 1},
            {name: "Link -- Provides a link to the Google Books page with more info", value: 2},
            {name: "Save -- Saves book to your personal bookshelf", value: 3},
            {name: "Exit -- Back to main menu", value: 4}
        ]
        user_input = prompt.select("Book Menu", choices, cycle: true, symbols: {marker: "→"})

        begin
    
            case user_input
            when 1
                puts "Summary:".bold + "#{@@book_instance.summary}"
                self.return_to_main_menu
            when 2
                puts TTY::Link.link_to("Click here for more info ", "#{@@book_instance.info_link}")
                self.return_to_main_menu
            when 3
                @@book_instance.save_book
                self.return_to_main_menu
            when 4
                BookstoreApp.display_menu
            else 
                puts "Error: You have entered an invalid response"
                self.display_book_menu
            end

        rescue Errno::ENOENT
            puts "Unfortunately, Google Books doesn't hold the information you are requesting for this book."
        end

    end

    def self.return_to_main_menu
        response = prompt.yes?("Would you like to return to the main menu?")
        case response
        when true
            BookstoreApp.display_menu
        when false
            self.display_book_menu
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
            puts "#{self.title} has been added to your personal bookshelf.".bold.cyan
            
            self.class.display_book_menu
    end
end

# new_book = Book.new("ZMwAEAAAQBAJ")
# new_book.print_book_details