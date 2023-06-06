require "colorize"
require_relative '../../config/environment.rb'
require_relative './user'
require_relative './book_list.rb'
require_relative './book'
require "tty-prompt"

class BookstoreApp 
    @@personal_bookshelf = []
    
    def self.start_app
        puts "Welcome to our bookstore!"
        
        bookshelf_color = Pastel.new.white.on_black.bold.detach
        bookshelf_img = bookshelf_color.("
            .--.                   .---.  .-.         
            .--|___        .-.     |~~~|  | |         
            .--|===|__     |_|     |~~~|--. |         
            |  |===|  |.---!~|  .--|   |--|_|         
            |%%|   |  ||===| |--|%%|   |  | |         
            |%%|   |  ||   | |__|  |   |  | |         
            |  |   |  ||===| |==|  |   |  |_|         
            |  |   |__||   |_|__|  |~~~|__| |         
            |  |===|--||===|~|--|%%|~~~|--| |         
            ^--^---'--^`---^-^--^--^---'--'-'         ")
            bookshelf_img.each_char {|c| putc c ; sleep 0.0030}
            puts ""
            puts "Please enter your first name:"
            first_name = gets.chomp
            puts "Please enter your last name:"
            last_name = gets.chomp
            $current_user = User.find_or_create_by(first_name: first_name, last_name: last_name)
        end
        
        
    def self.display_menu
        help_color = Pastel.new.blue.italic.detach
        prompt = TTY::Prompt.new(active_color: :cyan, help_color: help_color)
        choices = [
            {name: 'Search'.bold+' -- search for books by author, genre, or title', value: 1},
            {name: 'Bookshelf'.bold+' --returns your personal bookshelf', value: 2},
            {name: 'Bookshelf Menu'.bold+' -- Lists bookshelf commands', value: 3}
        ]

        user_input = prompt.select("Main Menu", choices, help: "(Use arrow keys, press enter to select)", show_help: :always, cycle:true, symbols: {marker: "→"})
        
        case user_input
        when 1
            self.search_menu
        when 2
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
        when 3
            self.display_bookshelf_menu
        else
            puts "Error: You have entered an invalid response"
        end

    end

    def self.search_menu
        prompt = TTY::Prompt.new(active_color: :cyan)
        choices = [
            {name: "Author", value: 1},
            {name: "Genre", value: 2},
            {name: "Title", value: 3}
        ]

        user_input = prompt.select("Search By:", choices, cycle:true, symbols: {marker: "→"})
        
        case user_input
        when 1
            puts "Enter author's name:"
            author = gets.chomp.gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "inauthor:", search_term: author)
            booklist.print_books
        when 2
            puts "Enter genre:"
            genre = gets.chomp.gsub(/\s+/, '+')
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
        puts ""
        puts "________________________".cyan

        response = prompt.yes?("Would you like more details on one of the above books?") do |q|
            q.suffix "Y/N"
        end
            case response
            when true
                puts "Enter the ID of your chosen book:"
                id = gets.chomp
                book = Book.new(id)
                book.print_book_details
            when false
                self.display_menu
            end
    end

    def self.display_bookshelf_menu
        puts "________________________".cyan
        puts "Bookshelf Menu".bold
        puts "add".bold + " -- adds a book to your bookshelf using book ID"
        puts "delete".bold + " -- deletes book from your bookshelf"
        puts "exit".bold + " -- back to main menu"
        puts "________________________".cyan
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

    def self.test_prompt

        user_input = prompt.select("Which menu would you like to go to?", help: "(Use arrow keys, press enter to select)", show_help: :always, cycle:true, symbols: {marker: "→"}) do |menu|
            menu.default 3

            menu.choice 'Main Menu'
            menu.choice 'Book'
            menu.choice 'Bookshelf'
        end
         
        case user_input
        when 'Main Menu'
            self.display_menu
        end

        
    end
end
# BookstoreApp.start_app
BookstoreApp.display_menu
# BookstoreApp.test_prompt