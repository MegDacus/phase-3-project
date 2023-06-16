require 'net/http'
require 'open-uri'
require 'json'
require 'box_puts'
require 'tty-prompt'

class Book
    prompt = TTY::Prompt.new(active_color: :cyan)
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
        prompt = TTY::Prompt.new
        if self.get_book.nil?
            prompt.error("Oh no! We are unable to get information for this book")
            BookstoreApp.display_menu
        else
            info = self.get_book
            @title = info["volumeInfo"]["title"]
            @author = info["volumeInfo"]["authors"]
            @isbn = info["volumeInfo"]["industryIdentifiers"].select{|isbn| isbn["type"] == "ISBN_10"}[0]["identifier"]
            @summary = info["volumeInfo"]["description"].gsub(/<[^>]*>/, "")

            if info["volumeInfo"]["categories"].nil?
                @categories = "No categories listed"
            else
                categories_string = info["volumeInfo"]["categories"].first
                @categories = categories_string
            end

            if info["saleInfo"]["listPrice"].nil?
                @price = "No price listed"
            else
                retail_price = info["saleInfo"]["listPrice"]
                price = retail_price["amount"]
                currency = retail_price["currencyCode"]
                @price = price
            end

            if info["volumeInfo"]["infoLink"].nil?
                @info_link = "No link listed"
            else 
                @info_link = info["volumeInfo"]["infoLink"]
            end
        end
    end

    def print_book_details
        BoxPuts.show(
            :align => "center",
            :title => "Book Details",
            :lines => ["Title: #{self.title}",
                "Author: #{self.author}",
                "Categories: #{self.categories}",
                "ISBN: #{self.isbn}",
                "Average Price: $ #{self.price}"]
        )
        
        puts "________________________".cyan
        puts ""
        self.class.display_book_menu
    end
    
    def self.display_book_menu 
        prompt = TTY::Prompt.new(active_color: :cyan)
        choices = [
            {name: "Summary".bold+" -- Returns summary of book", value: 1},
            {name: "Link".bold+" -- Provides a link to the Google Books page with more info", value: 2},
            {name: "Save".bold+" -- Saves book to your personal bookshelf", value: 3},
            {name: "Main Menu".bold+" -- Back to main menu", value: 4},
            {name: "Exit".bold+ " -- Exit the bookstore"}
        ]
        user_input = prompt.select("Book Menu", choices, cycle: true, symbols: {marker: "→"})
    
        case user_input
        when 1
            puts "Summary:".bold + "#{@@book_instance.summary}"
            self.return_to_main_menu
        when 2
            puts TTY::Link.link_to("Click here for more info ", "#{@@book_instance.info_link}")
            self.return_to_main_menu
        when 3
            @@book_instance.save_book
        when 4
            BookstoreApp.display_menu
        when 5 
            prompt.ok("Thank you for visiting The Bookstore!")
            exit
        end
    end

    def self.return_to_main_menu
        prompt = TTY::Prompt.new(active_color: :cyan)
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
                user_id: $current_user.id, 
                google_book_id: book_id
            )
            puts "#{self.title} has been added to your personal bookshelf.".bold.cyan
            
            Bookshelf.display_bookshelf
    end
end