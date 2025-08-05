require "application_system_test_case"

class EditBooksTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit edit_books_url
  #
  #   assert_selector "h1", text: "EditBooks"
  # end
  test "updating a Book" do
    book = books(:one)
    login_as book.user
    visit edit_book_url(book)
    fill_in "Title", with: "Updated Title"
    click_on "Update Book"
    assert_text "Book was successfully updated"
    book.reload
    assert_equal "Updated Title", book.title
  end
end
