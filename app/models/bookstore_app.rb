require "colorize"
require_relative '../../config/environment.rb'
require_relative './user'
require_relative './book_list.rb'
require_relative './book'

class BookstoreApp 
    
    @@personal_bookshelf = []
    
    def self.start_app
        puts "Welcome to our bookstore!"

        puts "Please enter your first name:"
        first_name = gets.chomp
        puts "Please enter your last name:"
        last_name = gets.chomp
        $current_user = User.find_or_create_by(first_name: first_name, last_name: last_name)
    end


    def self.display_menu
        puts ""
        puts "MAIN MENU".bold
        puts "Search".bold+" -- search for books by author, genre, or title"
        puts "Bookshelf".bold+" -- returns your personal bookshelf"
        puts "---------------------------------------------------".blue
        puts "Additional Menu Options".bold
        puts "Bookshelf Menu".bold+ " -- Lists bookshelf commands"
        puts ""
        puts ""
        puts "Answer:".bold
        response = gets.chomp
        
        case response
        when "Search"
            self.search_menu
        when "Bookshelf"
            puts "Welcome to your personal bookshelf!".bold
            i = 0
        
            Bookshelf.where(user_id: $current_user.id).each do |book|
                @@personal_bookshelf << book
                BoxPuts.show(
                    :align => "center",
                    :title => "Book #{i += 1}",
                    :lines => ["Title: #{book.title}",
                        "Author: #{book.author}",
                        "Categories: #{book.categories}",
                        "ISBN: #{book.isbn}",
                        "Average Price: $#{book.price}"]
                )
            end

            self.display_bookshelf_menu
        when "Bookshelf Menu"
            self.display_bookshelf_menu
        else
            puts "Error: You have entered an invalid response"
        end

    end

    def self.search_menu
        puts "Search by:"
        puts "1 - Author"
        puts "2 - Genre"
        puts "3 - Title"
        
        puts "Answer:"
        response = gets.chomp.to_i
        case response
        when 1
            puts "Enter author's name:"
            author = gets.chomp.gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "inauthor:", search_term: author)
            booklist.print_books
        when 2
            puts "Enter genre:"
            genre = gets.chomp
            booklist = BookList.new(search_category: "subject:", search_term: genre)
            booklist.print_books
        when 3
            puts "Enter title:"
            title = gets.chomp.gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "intitle:", search_term: title)
            booklist.print_books
        else  
            puts "Error: You have entered an invalid response."
        end


        puts "Would you like more details on one of the above books? (Y or N)"
        answer = gets.chomp
            case answer
            when "Y"
                puts "Enter the ID of your chosen book:"
                id = gets.chomp
                book = Book.new(id)
                book.print_book_details
            end
    end

    def self.display_bookshelf_menu
        puts "________________________".blue
        puts "Bookshelf Menu".bold
        puts "add".bold + " -- adds a book to your bookshelf using book ID"
        puts "delete".bold + " -- deletes book from your bookshelf"
        puts "exit".bold + " -- back to main menu"
        puts "________________________".blue
        puts "Choice:"
        response = gets.chomp

        case response
        when "add"
            puts "Please enter book ID here:"
            id = gets.chomp
            book = Book.new(id)
            book.save_book
        when "delete"
            puts "Enter bookshelf book number here:"
            book_array_index = gets.chomp.to_i - 1
            book_to_delete = @@personal_bookshelf[book_array_index]
            Bookshelf.destroy(book_to_delete.id)
            self.display_bookshelf_menu
        when "exit"
            self.display_menu
        else 
            puts "Error: You have entered an invalid response."
        end

    end
end
BookstoreApp.start_app
BookstoreApp.display_menu