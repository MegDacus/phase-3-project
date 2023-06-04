class CreateBookshelvesTable < ActiveRecord::Migration[6.1]
  def change
    create_table :bookshelves do |t|
      t.string :title
      t.string :author
      t.string :summary
      t.string :categories
      t.integer :price
      t.integer :isbn
      t.integer :user_id
    end
  end
end
