require 'active_record'
class Bookshelf < ActiveRecord::Base
    belongs_to :user
    @@personal_bookshelf = []

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

    def self.display_bookshelf_menu
        prompt = TTY::Prompt.new(active_color: :cyan)
        puts "________________________".cyan

        choices = [
            {name: "Add".bold+ " -- Search for books to add to your bookshelf", value: 1},
            {name: "Delete".bold+ " -- Deletes book from your bookshelf", value: 2},
            {name: "Main Menu".bold+ " -- Back to main menu", value: 3},
            {name: "Exit".bold+" -- Exit the bookstore", value: 4}
        ]

        user_input = prompt.select("Bookshelf Menu", choices, cycle: true, symbols: {marker: "→"})

        case user_input
        when 1
            BookstoreApp.search_menu
        when 2
            answer = prompt.yes?("Are you sure you want to delete a book from your bookshelf?")
                case answer
                when true 
                    book_array_index = prompt.ask("Please enter book number:", required: true).to_i - 1
                    book_to_delete = @@personal_bookshelf[book_array_index]
                    Bookshelf.destroy(book_to_delete.id)
                    prompt.ok("You have succesfully removed #{book_to_delete.title} from your bookshelf.")
                    self.display_bookshelf_menu
                when false
                    self.display_bookshelf_menu
                end
        when 3
            BookstoreApp.display_menu
        when 4
            prompt.ok("Thank you for visiting The Bookstore!")
            exit
        end
    end
end