require "application_system_test_case"

class CreateBookFromDashboardsTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit create_book_from_dashboards_url
  #
  #   assert_selector "h1", text: "CreateBookFromDashboard"
  # end
  #
  test "create book from dashboard" do
    user = users(:one)
    login_as(user)
    visit root_path
    click_on "Add a Book"
    click_on "Add manually"
    fill_in "Title", with: "Test Book"
    fill_in "Author", with: "Test Author"
    fill_in "Start date", with: "01/01/2023"
    click_on "Create Book"
    assert_text "Book was successfully created"
    assert_text "Mark as complete"
  end

  test "show celebration modal when completing book from dashboard" do
    user = users(:one)
    login_as(user)

    author = Author.create!(name: "Test Author")
    # Create a book in progress
    book = user.books.create!(
      title: "Test Book to Complete",
      start_date: 1.week.ago,
      finish_date: nil,
      authors: [ author ]
    )

    visit root_path
    assert_text "Mark as complete"

    # Mark the book as complete
    click_on "Mark as complete"

    # Check that celebration modal appears
    assert_text "Congratulations!", wait: 5
    assert_text "book!", wait: 2  # "You've completed your Xth book!"
    assert_text "Test Book to Complete"
    assert_text "by Test Author"

    # Check that the book section updates to show "Start a New Book"
    assert_text "Start a New Book"
    assert_text "You currently have no books in progress"
  end
end
