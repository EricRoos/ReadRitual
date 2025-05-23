require "test_helper"

class BookSaverTest < ActiveSupport::TestCase
  def setup
    @user = users(:one) # Assuming you have a fixture for users
    @params = {
      start_date: Date.new(2025, 5, 1),
      finish_date: Date.new(2025, 5, 15),
      title: "The Great Gatsby",
      authors: [ "F. Scott Fitzgerald", "f. scott fitzgerald", "Ernest Hemingway" ]
    }
  end

  test "creates a book with the correct attributes" do
    book_saver = BookSaver.new(@user, @params)
    book = book_saver.build

    assert_equal "The Great Gatsby", book.title
    assert_equal Date.new(2025, 5, 1), book.start_date
    assert_equal Date.new(2025, 5, 15), book.finish_date
    assert_equal @user, book.user
  end

  test "associates existing authors case-insensitively" do
    existing_author = Author.create!(name: "F. Scott Fitzgerald")
    book_saver = BookSaver.new(@user, @params)
    book = book_saver.build

    assert_includes book.authors, existing_author
    assert_equal 2, book.authors.size # One existing, one new
  end

  test "creates new authors if they do not exist" do
    book_saver = BookSaver.new(@user, @params)
    book = book_saver.build
    book.save

    new_author = Author.find_by(name: "Ernest Hemingway")
    assert_not_nil new_author
    assert_includes book.authors.map(&:name), "Ernest Hemingway"
  end

  test "does not create duplicate authors for case-insensitive matches" do
    Author.create!(name: "F. Scott Fitzgerald")
    book_saver = BookSaver.new(@user, @params)
    book = book_saver.build

    assert_equal 1, Author.where("lower(name) = ?", "f. scott fitzgerald".downcase).count
  end
end
