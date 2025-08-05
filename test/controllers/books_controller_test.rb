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
end
