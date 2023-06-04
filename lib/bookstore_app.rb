require "colorize"
require_relative "./book_list"
require_relative "./book"


class BookstoreApp
    def initialize
        # bookshelf = Bookshelf.new
        puts "Welcome to our bookstore!"

        puts "Please enter your first name:"
        first_name = gets.chomp
        puts "Please enter your last name:"
        last_name = gets.chomp
        user = User.create(first_name: first_name, last_name: last_name)
    end

    def display_menu
        puts ""
        puts "MAIN MENU".bold
        puts "Search".bold+" -- search for books by author, genre, or title"
        puts "Bookshelf".bold+" -- returns your personal bookshelf"
        puts "---------------------------------------------------".blue
        puts "Additional Menu Options".bold
        puts "Book Menu".bold+" -- Lists indidual book commands"
        puts "Bookshelf Menu".bold+ " -- Lists bookshelf commands"
        puts ""
        puts ""
        puts "Answer:".bold
        response = gets.chomp
        
        case response
        when "Search"
            self.search_menu
        when "Bookshelf"
            self.my_books
        when "Book Menu"
            self.display_book_menu
        when "Bookshelf Menu"
            self.display_bookshelf_menu
        else
            puts "Error: You have entered an invalid response"
        end

    end

    def search_menu
        booklist = BookList.new
        puts "Search by:"
        puts "1 - Author"
        puts "2 - Genre"
        puts "3 - Title"

        puts "Answer:"
        response = gets.chomp.to_i
            if response == 1
                booklist.search_category = "inauthor:"
                puts "Enter author's name:"
                author = gets.chomp.gsub(/\s+/, '+')
                booklist.search_item = author
            elsif response == 2
                booklist.search_category = "subject:"
                puts "Enter genre:"
                genre = gets.chomp
                booklist.search_item = genre 
            elsif response == 3
                booklist.search_category = "intitle:"
                puts "Enter title:"
                title = gets.chomp.gsub(/\s+/, '+')
                booklist.search_item = title
            else  
                puts "Error: You have entered an invalid response."
            end
    end
    
    
    
end
test = BookstoreApp.new
test.display_menu

