class AddColumnToBookshelvesTable < ActiveRecord::Migration[6.1]
  def change
    add_column :bookshelves, :google_book_id, :string
  end
end
