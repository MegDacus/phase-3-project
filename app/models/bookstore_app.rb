require "colorize"
require_relative '../../config/environment.rb'
require_relative './user'
require_relative './book_list.rb'
require_relative './book'
require "tty-prompt"
require "curses"

class BookstoreApp 
    @@personal_bookshelf = []
    
    def self.start_app
        prompt = TTY::Prompt.new(active_color: :cyan)
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
            first_name = prompt.ask("Please enter your first name:")
            last_name = prompt.ask("Please enter your last name:")
            $current_user = User.find_or_create_by(first_name: first_name, last_name: last_name)
    end

    def self.display_bookshelf
        prompt = TTY::Prompt.new(active_color: :cyan)
        i = 0
        bookshelf = Bookshelf.where(user_id: $current_user.id)

        if bookshelf.empty?
            prompt.ok("Your bookshelf is currently empty!")
        else
            bookshelf.each do |book|
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
        end
        self.display_bookshelf_menu
    end
        
    def self.display_menu
        help_color = Pastel.new.blue.italic.detach
        prompt = TTY::Prompt.new(active_color: :cyan, help_color: help_color)
        choices = [
            {name: 'Search'.bold+' -- search for books by author, genre, or title', value: 1},
            {name: 'Bookshelf'.bold+' --returns your personal bookshelf', value: 2},
            {name: 'Bookshelf Menu'.bold+' -- Lists bookshelf commands', value: 3},
            {name: 'Exit'.bold+' -- Exit the bookstore', value: 4}
        ]

        user_input = prompt.select("Main Menu", choices, help: "(Use arrow keys, press enter to select)", show_help: :always, cycle:true, symbols: {marker: "→"})
        
        case user_input
        when 1
            self.search_menu
        when 2
            puts "Welcome to your personal bookshelf!".bold
            self.display_bookshelf
            self.display_bookshelf_menu
        when 3
            self.display_bookshelf_menu
        when 4
            puts "Thank you for visiting the bookstore!"
            exit 1
        else
            puts "Error: You have entered an invalid response"
        end

    end

    def self.search_menu
        prompt = TTY::Prompt.new(active_color: :cyan)
        choices = [
            {name: "Author", value: 1},
            {name: "Genre", value: 2},
            {name: "Title", value: 3},
            {name: "Google Books ID", value: 4}
        ]

        user_input = prompt.select("Search By:", choices, cycle:true, symbols: {marker: "→"})
        
        case user_input
        when 1
            author = prompt.ask("Enter author's name:").gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "inauthor:", search_term: author)
            booklist.print_books
        when 2
            genre = prompt.ask("Enter genre:").gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "subject:", search_term: genre)
            booklist.print_books
        when 3
            title = prompt.ask("Enter title:").gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "intitle:", search_term: title)
            booklist.print_books
        when 4
            id = prompt.ask("Enter ID:")
            book = Book.new(id)
            book.print_book_details
        else  
            prompt.error("Error: You have entered an invalid response.")
        end
        puts ""
        puts "________________________".cyan

        response = prompt.yes?("Would you like more details on one of the above books?") do |q|
            q.suffix "Y/N"
        end
            case response
            when true
                book_number = prompt.ask("Enter the # of your chosen book:")
                id = BookList.get_book_id_by_number(book_number)
                book = Book.new(id)
                book.print_book_details
            when false
                self.display_menu
            end
    end

    def self.display_bookshelf_menu
        prompt = TTY::Prompt.new(active_color: :cyan)
        puts "________________________".cyan

        choices = [
            {name: "Add".bold+ " -- Search for books to add to your bookshelf", value: 1},
            {name: "Delete".bold+ " -- Deletes book from your bookshelf", value: 2},
            {name: "Exit".bold+ " -- Back to main menu", value: 3}
        ]

        user_input = prompt.select("Bookshelf Menu", choices, cycle: true, symbols: {marker: "→"})

        case user_input
        when 1
            self.search_menu
        when 2
            book_array_index = prompt.ask("Please enter book number:").to_i - 1
            book_to_delete = @@personal_bookshelf[book_array_index]
            Bookshelf.destroy(book_to_delete.id)
            prompt.ok("You have succesfully removed #{book_to_delete.title} from your bookshelf.")
            self.display_bookshelf_menu
        when 3
            self.display_menu
        else 
            prompt.error("Error: You have entered an invalid response")
            self.display_bookshelf_menu
        end

    end
end
BookstoreApp.start_app
BookstoreApp.display_menu
# BookstoreApp.test_prompt