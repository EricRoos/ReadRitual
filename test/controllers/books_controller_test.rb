require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one)
    @user = users(:one)
    login_as(@user)
  end

  test "should get index" do
    get books_url
    assert_response :success
  end

  test "should get new" do
    get new_book_url
    assert_response :success
  end

  test "should create book" do
    assert_difference("Book.count") do
      post books_url, params: { book: { authors: [ { name: "author one" } ], finish_date: @book.finish_date, start_date: @book.start_date, title: @book.title, user_id: @book.user_id } }
    end

    assert_redirected_to book_url(Book.last)
  end

  test "should show book" do
    get book_url(@book)
    assert_response :success
  end

  test "should get edit" do
    get edit_book_url(@book)
    assert_response :success
  end

  test "should update book" do
    patch book_url(@book), params: { book: { authors: [ { name: "author one" } ], finish_date: @book.finish_date, start_date: @book.start_date, title: @book.title, user_id: @book.user_id } }
    assert_redirected_to book_url(@book)
  end

  test "should show celebration modal when completing book from dashboard" do
    # Create a book that's in progress (no finish_date)
    author = Author.create!(name: "Test Author")
    in_progress_book = @user.books.create!(
      title: "In Progress Book",
      start_date: 1.week.ago,
      finish_date: nil,
      authors: [ author ]
    )

    # Mark as complete from dashboard (return_to: root_path)
    patch book_url(in_progress_book),
          params: {
            book: { finish_date: Date.today },
            return_to: root_path
          },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type

    # Verify the turbo stream response includes celebration modal
    assert_match /celebration-modal/, response.body
    assert_match /Congratulations/, response.body

    # Verify book was actually completed
    in_progress_book.reload
    assert_not_nil in_progress_book.finish_date
    assert_equal Date.today, in_progress_book.finish_date
  end

  test "should not show celebration modal when updating book from other pages" do
    patch book_url(@book),
          params: {
            book: { finish_date: Date.today },
            return_to: book_path(@book)
          }

    assert_redirected_to book_url(@book)
    # Should not be a turbo stream response when not from dashboard
  end

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete book_url(@book)
    end

    assert_redirected_to books_url
  end

  test "should filter books by author ids (intersection logic)" do
    # Create test authors
    author1 = Author.create!(name: "Author One")
    author2 = Author.create!(name: "Author Two") 
    author3 = Author.create!(name: "Author Three")

    # Create books with different author combinations
    book1 = @user.books.create!(
      title: "Book by Author 1 only",
      start_date: Date.current,
      authors: [author1]
    )
    
    book2 = @user.books.create!(
      title: "Book by Author 1 and 2",
      start_date: Date.current,
      authors: [author1, author2]
    )
    
    book3 = @user.books.create!(
      title: "Book by Author 2 and 3",
      start_date: Date.current,
      authors: [author2, author3]
    )
    
    book4 = @user.books.create!(
      title: "Book by all three authors",
      start_date: Date.current,
      authors: [author1, author2, author3]
    )

    # Test filtering by single author
    get books_url, params: { author_ids: [author1.id] }
    assert_response :success
    # Should include books 1, 2, and 4 (all books with author1)
    assert_includes response.body, "Book by Author 1 only"
    assert_includes response.body, "Book by Author 1 and 2"
    assert_includes response.body, "Book by all three authors"
    assert_not_includes response.body, "Book by Author 2 and 3"

    # Test filtering by two authors (intersection logic)
    get books_url, params: { author_ids: [author1.id, author2.id] }
    assert_response :success
    # Should only include books 2 and 4 (books with BOTH author1 AND author2)
    assert_not_includes response.body, "Book by Author 1 only"
    assert_includes response.body, "Book by Author 1 and 2"
    assert_not_includes response.body, "Book by Author 2 and 3"
    assert_includes response.body, "Book by all three authors"

    # Test filtering by all three authors
    get books_url, params: { author_ids: [author1.id, author2.id, author3.id] }
    assert_response :success
    # Should only include book 4 (book with ALL three authors)
    assert_not_includes response.body, "Book by Author 1 only"
    assert_not_includes response.body, "Book by Author 1 and 2"
    assert_not_includes response.body, "Book by Author 2 and 3"
    assert_includes response.body, "Book by all three authors"
  end
end
