class AddBooksAuthors < ActiveRecord::Migration[8.0]
  def up
    create_table "authors_books", id: false do |t|
      t.bigint "book_id", null: false
      t.bigint "author_id", null: false
    end

    # Composite primary key
    execute "ALTER TABLE authors_books ADD PRIMARY KEY (book_id, author_id);"
  end

  def down
    drop_table "authors_books"
  end
end
