class Bookshelf < ActiveRecord::Base
    belongs_to :user

    def display_bookshelf_menu
        puts "Welcome to your personal bookshelf!"
        puts "my_books -- lists all books currently on your bookshelf"
        puts "delete(book_id) -- deletes book from your bookshelf"
    end
end