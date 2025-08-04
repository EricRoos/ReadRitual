require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  test "should split authors into existing authors" do
    author1 = Author.create!(name: "Author One")
    author2 = Author.create!(name: "Author Two")
    book = Book.create!(user: users(:one), title: "Test Book", start_date: Date.current, authors: [ author1 ])

    author1.split_into([ author2.id ])

    book.reload

    assert_includes book.authors, author2
    refute_includes book.authors, author1
    assert_not Author.exists?(author1.id)
  end

  test "should split authors into multiple existing authors" do
    author1 = Author.create!(name: "Author One")
    author2 = Author.create!(name: "Author Two")
    author3 = Author.create!(name: "Author Three")
    book = Book.create!(user: users(:one), title: "Test Book", start_date: Date.current, authors: [ author1 ])

    author1.split_into([ author2.id, author3.id ])

    book.reload

    assert_includes book.authors, author2
    assert_includes book.authors, author3
    refute_includes book.authors, author1
    assert_not Author.exists?(author1.id)
    assert_equal 2, book.authors.count
  end

  test "should split author with multiple books" do
    author1 = Author.create!(name: "Author One")
    author2 = Author.create!(name: "Author Two")
    book1 = Book.create!(user: users(:one), title: "Test Book 1", start_date: Date.current, authors: [ author1 ])
    book2 = Book.create!(user: users(:one), title: "Test Book 2", start_date: Date.current, authors: [ author1 ])

    author1.split_into([ author2.id ])

    book1.reload
    book2.reload

    assert_includes book1.authors, author2
    assert_includes book2.authors, author2
    refute_includes book1.authors, author1
    refute_includes book2.authors, author1
    assert_not Author.exists?(author1.id)
  end

  test "should handle splitting author with no books" do
    author1 = Author.create!(name: "Author One")
    author2 = Author.create!(name: "Author Two")

    author1.split_into([ author2.id ])

    assert_not Author.exists?(author1.id)
    assert Author.exists?(author2.id)
  end

  test "should handle splitting into empty array" do
    author1 = Author.create!(name: "Author One")
    book = Book.create!(user: users(:one), title: "Test Book", start_date: Date.current, authors: [ author1 ])

    author1.split_into([])

    book.reload

    assert_empty book.authors
    assert_not Author.exists?(author1.id)
  end

  test "should handle splitting into non-existent author ids" do
    author1 = Author.create!(name: "Author One")
    book = Book.create!(user: users(:one), title: "Test Book", start_date: Date.current, authors: [ author1 ])

    author1.split_into([ 999, 1000 ])

    book.reload

    assert_empty book.authors
    assert_not Author.exists?(author1.id)
  end

  test "should not duplicate authors when target author already exists on book" do
    author1 = Author.create!(name: "Author One")
    author2 = Author.create!(name: "Author Two")
    book = Book.create!(user: users(:one), title: "Test Book", start_date: Date.current, authors: [ author1, author2 ])

    author1.split_into([ author2.id ])

    book.reload

    assert_includes book.authors, author2
    refute_includes book.authors, author1
    assert_equal 1, book.authors.count
    assert_not Author.exists?(author1.id)
  end

  test "should handle mixed valid and invalid author ids" do
    author1 = Author.create!(name: "Author One")
    author2 = Author.create!(name: "Author Two")
    book = Book.create!(user: users(:one), title: "Test Book", start_date: Date.current, authors: [ author1 ])

    author1.split_into([ author2.id, 999 ])

    book.reload

    assert_includes book.authors, author2
    refute_includes book.authors, author1
    assert_equal 1, book.authors.count
    assert_not Author.exists?(author1.id)
  end
end
