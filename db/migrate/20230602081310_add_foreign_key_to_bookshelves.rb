class AddForeignKeyToBookshelves < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :bookshelves, :users
  end
end
