class ChangeIsbnInBookshelvesToString < ActiveRecord::Migration[6.1]
  def change
    change_column :bookshelves, :isbn, :string
  end
end
