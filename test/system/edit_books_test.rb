require "application_system_test_case"

class EditBooksTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit edit_books_url
  #
  #   assert_selector "h1", text: "EditBooks"
  # end
  test "updating a Book" do
    book = books(:one)
    # Ensure the book has an author first
    if book.authors.empty?
      book.authors.create!(name: "Original Author")
    end

    login_as book.user
    visit edit_book_url(book)
    fill_in "Title", with: "Updated Title"
    click_on "Update Book"
    book = Book.find(book.id)
    assert_text "Book was successfully updated"
    assert_text "Updated Title"
  end
end
