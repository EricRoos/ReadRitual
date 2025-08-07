require "test_helper"

class AuthoringTest < ActiveSupport::TestCase
  setup do
    # Clean up any existing data to ensure clean test state
    Book.includes(:user).destroy_all
    Author.destroy_all

    @user = users(:one)
    @author1 = Author.create!(name: "Test Author 1")
    @author2 = Author.create!(name: "Test Author 2")
    @author3 = Author.create!(name: "Test Author 3")
  end

  test "should return empty array when no books exist" do
    authorings = Authoring.all
    assert_equal [], authorings
  end

  test "should return authoring for book with single author" do
    book = Book.create!(
      user: @user,
      title: "Single Author Book",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    authorings = Authoring.all([ book.id ])

    assert_equal 1, authorings.length
    authoring = authorings.first

    assert_equal book, authoring.book
    assert_equal [ @author1 ], authoring.authors
  end

  test "should return authoring for book with multiple authors" do
    book = Book.create!(
      user: @user,
      title: "Multi Author Book",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    authorings = Authoring.all([ book.id ])

    assert_equal 1, authorings.length
    authoring = authorings.first

    assert_equal book, authoring.book
    assert_equal 2, authoring.authors.length
    assert_includes authoring.authors, @author1
    assert_includes authoring.authors, @author2
  end

  test "should return authorings for multiple books" do
    book1 = Book.create!(
      user: @user,
      title: "Book 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Book 2",
      start_date: Date.current,
      authors: [ @author2, @author3 ]
    )

    authorings = Authoring.all([ book1.id, book2.id ])

    assert_equal 2, authorings.length

    # Sort by book title for consistent testing
    authorings.sort_by! { |a| a.book.title }

    # Test first book
    assert_equal book1, authorings[0].book
    assert_equal [ @author1 ], authorings[0].authors

    # Test second book
    assert_equal book2, authorings[1].book
    assert_equal 2, authorings[1].authors.length
    assert_includes authorings[1].authors, @author2
    assert_includes authorings[1].authors, @author3
  end

  test "should only return books that have authors" do
    # Create a book with an author first
    book_with_author = Book.create!(
      user: @user,
      title: "Book With Author",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    # Create another book and then remove its author via SQL
    book_without_author = Book.create!(
      user: @user,
      title: "Book Without Author",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    # Remove the author association directly in the database
    ActiveRecord::Base.connection.execute(
      "DELETE FROM authors_books WHERE book_id = #{book_without_author.id}"
    )

    authorings = Authoring.all([ book_with_author.id, book_without_author.id ])

    # Should only return the book with authors
    assert_equal 1, authorings.length
    authoring = authorings.first

    assert_equal book_with_author, authoring.book
    assert_equal [ @author1 ], authoring.authors
  end

  test "should handle books with same author" do
    book1 = Book.create!(
      user: @user,
      title: "Book 1 by Author 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Book 2 by Author 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    authorings = Authoring.all([ book1.id, book2.id ])

    assert_equal 2, authorings.length

    # Both books should have the same author
    authorings.each do |authoring|
      assert_equal [ @author1 ], authoring.authors
    end

    # But different books
    book_titles = authorings.map { |a| a.book.title }.sort
    assert_equal [ "Book 1 by Author 1", "Book 2 by Author 1" ], book_titles
  end

  test "should return correct authoring objects with proper attributes" do
    book = Book.create!(
      user: @user,
      title: "Test Book",
      start_date: Date.current,
      finish_date: Date.current + 1.day,
      authors: [ @author1, @author2 ]
    )

    authorings = Authoring.all([ book.id ])
    authoring = authorings.first

    # Test that the authoring object has the correct structure
    assert_respond_to authoring, :book
    assert_respond_to authoring, :authors

    # Test that the book has all its attributes
    assert_equal "Test Book", authoring.book.title
    assert_equal Date.current, authoring.book.start_date
    assert_equal Date.current + 1.day, authoring.book.finish_date
    assert_equal @user, authoring.book.user

    # Test that authors have their attributes
    assert_equal 2, authoring.authors.length
    author_names = authoring.authors.map(&:name).sort
    assert_equal [ "Test Author 1", "Test Author 2" ], author_names
  end

  test "should handle books with many authors efficiently" do
    # Create a book with many authors to test performance characteristics
    many_authors = (1..5).map { |i| Author.create!(name: "Author #{i}") }

    book = Book.create!(
      user: @user,
      title: "Book with Many Authors",
      start_date: Date.current,
      authors: many_authors
    )

    authorings = Authoring.all([ book.id ])

    assert_equal 1, authorings.length
    authoring = authorings.first

    assert_equal book, authoring.book
    assert_equal 5, authoring.authors.length

    # Verify all authors are present
    author_names = authoring.authors.map(&:name).sort
    expected_names = (1..5).map { |i| "Author #{i}" }
    assert_equal expected_names, author_names
  end

  test "should scope by book_ids when provided" do
    book1 = Book.create!(
      user: @user,
      title: "Book 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Book 2",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    book3 = Book.create!(
      user: @user,
      title: "Book 3",
      start_date: Date.current,
      authors: [ @author3 ]
    )

    # Test scoping to specific books
    authorings = Authoring.all([ book1.id, book3.id ])

    assert_equal 2, authorings.length

    book_titles = authorings.map { |a| a.book.title }.sort
    assert_equal [ "Book 1", "Book 3" ], book_titles

    # Verify the correct authors are returned
    authors_by_book = authorings.index_by { |a| a.book.title }
    assert_equal [ @author1 ], authors_by_book["Book 1"].authors
    assert_equal [ @author3 ], authors_by_book["Book 3"].authors
  end

  test "should return empty when scoped to non-existent book_ids" do
    Book.create!(
      user: @user,
      title: "Existing Book",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    # Scope to non-existent book IDs
    authorings = Authoring.all([ 999999, 888888 ])

    assert_equal [], authorings
  end

  test "should return empty array when book_ids is empty array" do
    book1 = Book.create!(
      user: @user,
      title: "Book 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Book 2",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    # Empty array should return empty array (defensive behavior)
    authorings_empty = Authoring.all([])

    assert_equal 0, authorings_empty.length
    assert_equal [], authorings_empty
  end

  test "should handle single book_id in array" do
    book1 = Book.create!(
      user: @user,
      title: "Book 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Book 2",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    # Scope to single book
    authorings = Authoring.all([ book1.id ])

    assert_equal 1, authorings.length
    assert_equal book1, authorings.first.book
    assert_equal [ @author1 ], authorings.first.authors
  end

  # Tests for the grouped method
  test "should return empty hash when no book_ids provided to grouped" do
    Book.create!(
      user: @user,
      title: "Test Book",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    grouped = Authoring.grouped([])
    assert_equal({}, grouped)
  end

  test "should group books by same author set" do
    # Create multiple books by the same author
    book1 = Book.create!(
      user: @user,
      title: "Book 1 by Author 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Book 2 by Author 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    grouped = Authoring.grouped([ book1.id, book2.id ])

    # Should have one group with authors array as key
    assert_equal 1, grouped.keys.length
    authors_key = grouped.keys.first
    assert_equal [ @author1 ], authors_key

    # The group should contain both books
    books_in_group = grouped[authors_key]
    assert_equal 2, books_in_group.length
    assert_includes books_in_group, book1
    assert_includes books_in_group, book2
  end

  test "should group books by same multi-author set" do
    # Create multiple books by the same pair of authors
    book1 = Book.create!(
      user: @user,
      title: "Collaboration 1",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Collaboration 2",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    grouped = Authoring.grouped([ book1.id, book2.id ])

    # Should have one group with authors array as key
    assert_equal 1, grouped.keys.length
    authors_key = grouped.keys.first
    assert_equal [ @author1, @author2 ], authors_key

    # The group should contain both books
    books_in_group = grouped[authors_key]
    assert_equal 2, books_in_group.length
    assert_includes books_in_group, book1
    assert_includes books_in_group, book2
  end

  test "should create separate groups for different author sets" do
    # Create books with different author combinations
    book1 = Book.create!(
      user: @user,
      title: "Solo by Author 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Solo by Author 2",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    book3 = Book.create!(
      user: @user,
      title: "Collaboration",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    grouped = Authoring.grouped([ book1.id, book2.id, book3.id ])

    # Should have three different groups
    assert_equal 3, grouped.keys.length

    # Find the groups by their author arrays
    author1_group = grouped.find { |authors, books| authors == [ @author1 ] }
    author2_group = grouped.find { |authors, books| authors == [ @author2 ] }
    collaboration_group = grouped.find { |authors, books| authors == [ @author1, @author2 ] }

    assert_not_nil author1_group
    assert_not_nil author2_group
    assert_not_nil collaboration_group

    # Verify each group has the correct books
    assert_equal [ book1 ], author1_group[1]
    assert_equal [ book2 ], author2_group[1]
    assert_equal [ book3 ], collaboration_group[1]
  end

  test "should handle mixed single and multi-author books with same authors" do
    # Create books where same authors appear individually and together
    solo_book1 = Book.create!(
      user: @user,
      title: "Solo by Author 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    solo_book2 = Book.create!(
      user: @user,
      title: "Solo by Author 2",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    collab_book = Book.create!(
      user: @user,
      title: "Collaboration",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    another_solo1 = Book.create!(
      user: @user,
      title: "Another Solo by Author 1",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    all_book_ids = [ solo_book1.id, solo_book2.id, collab_book.id, another_solo1.id ]
    grouped = Authoring.grouped(all_book_ids)

    # Should have three groups: author1 solo, author2 solo, author1+author2 collab
    assert_equal 3, grouped.keys.length

    # Find groups by their author arrays
    author1_group = grouped.find { |authors, books| authors == [ @author1 ] }
    author2_group = grouped.find { |authors, books| authors == [ @author2 ] }
    collaboration_group = grouped.find { |authors, books| authors == [ @author1, @author2 ] }

    assert_not_nil author1_group
    assert_not_nil author2_group
    assert_not_nil collaboration_group

    # Author 1 solo books should be grouped together
    author1_books = author1_group[1]
    assert_equal 2, author1_books.length
    assert_includes author1_books, solo_book1
    assert_includes author1_books, another_solo1

    # Author 2 solo book
    assert_equal [ solo_book2 ], author2_group[1]

    # Collaboration book
    assert_equal [ collab_book ], collaboration_group[1]
  end

  test "should handle books with different multi-author combinations" do
    # Create books with different combinations of the same authors
    book_12 = Book.create!(
      user: @user,
      title: "Authors 1 & 2",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    book_13 = Book.create!(
      user: @user,
      title: "Authors 1 & 3",
      start_date: Date.current,
      authors: [ @author1, @author3 ]
    )

    book_123 = Book.create!(
      user: @user,
      title: "All Three Authors",
      start_date: Date.current,
      authors: [ @author1, @author2, @author3 ]
    )

    grouped = Authoring.grouped([ book_12.id, book_13.id, book_123.id ])

    # Should have three separate groups
    assert_equal 3, grouped.keys.length

    # Find groups by their author arrays
    group_12 = grouped.find { |authors, books| authors == [ @author1, @author2 ] }
    group_13 = grouped.find { |authors, books| authors == [ @author1, @author3 ] }
    group_123 = grouped.find { |authors, books| authors == [ @author1, @author2, @author3 ] }

    assert_not_nil group_12
    assert_not_nil group_13
    assert_not_nil group_123

    assert_equal [ book_12 ], group_12[1]
    assert_equal [ book_13 ], group_13[1]
    assert_equal [ book_123 ], group_123[1]
  end

  test "should return empty hash for non-existent book_ids in grouped" do
    Book.create!(
      user: @user,
      title: "Existing Book",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    # Call grouped with non-existent book IDs
    grouped = Authoring.grouped([ 999999, 888888 ])

    assert_equal({}, grouped)
  end
end
