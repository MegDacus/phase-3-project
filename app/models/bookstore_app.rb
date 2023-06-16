require "colorize"
require_relative '../../config/environment.rb'
require_relative './user'
require_relative './bookshelf'
require "tty-prompt"

class BookstoreApp 
    
    def self.start_app
        prompt = TTY::Prompt.new(active_color: :cyan)
        puts "Welcome to The Bookstore!"
        
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
        
    def self.display_menu
        prompt = TTY::Prompt.new(active_color: :cyan)
        choices = [
            {name: 'Search'.bold+' -- search for books by author, genre, or title', value: 1},
            {name: 'Bookshelf'.bold+' --returns your personal bookshelf', value: 2},
            {name: 'Bookshelf Menu'.bold+' -- Lists bookshelf commands', value: 3},
            {name: 'Exit'.bold+' -- Exit the bookstore', value: 4}
        ]

        user_input = prompt.select("Main Menu", choices, cycle:true, symbols: {marker: "→"})
        
        case user_input
        when 1
            self.search_menu
        when 2
            puts "Welcome to your personal bookshelf!".bold
            Bookshelf.display_bookshelf
            self.display_bookshelf_menu
        when 3
            Bookshelf.display_bookshelf_menu
        when 4
            prompt.ok("Thank you for visiting The Bookstore!")
            exit
        end

    end

    def self.search_menu
        prompt = TTY::Prompt.new(active_color: :cyan)
        choices = [
            {name: "Author", value: 1},
            {name: "Subject", value: 2},
            {name: "Title", value: 3},
            {name: "ISBN", value: 4}
        ]
       
        user_input = prompt.select("Search By:", choices, cycle:true, symbols: {marker: "→"})
        
        case user_input
        when 1
            max = prompt.slider("How many books would you like returned?", min:5, max: 30, step: 5)
            author = prompt.ask("Enter author's name:", required: true).gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "inauthor:", search_term: author, max: max + 10)
            booklist.print_books
        when 2
            max = prompt.slider("How many books would you like returned?", min:5, max: 30, step: 5)
            subject = prompt.ask("Enter subject:", required: true).gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "subject:", search_term: subject, max: max + 10)
            booklist.print_books
        when 3
            title = prompt.ask("Enter title:", required: true).gsub(/\s+/, '+')
            booklist = BookList.new(search_category: "intitle:", search_term: title)
            booklist.print_books
        when 4
            isbn = prompt.ask("Enter ISBN:", required: true)
            book_id = nil
            booklist = BookList.new(search_category: "isbn:", search_term: isbn).get_books
            
            booklist.each do |book|
                id = book["id"]
                book_id = id
            end

            Book.new(book_id).print_book_details
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

end
BookstoreApp.start_app
BookstoreApp.display_menu