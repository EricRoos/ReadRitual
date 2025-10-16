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

    # Check that the book section updates to show "Add a Book"
    assert_text "Add a Book"
    assert_text "You don't have any books in progress right now"
  end

  test "show goal achievement celebration when reaching reading goal" do
    user = users(:one)
    # Set a low goal for testing
    user.update!(books_per_year_goal: 3)
    login_as(user)

    author = Author.create!(name: "Test Author")

    # Create 2 completed books (so the next one will meet the goal)
    2.times do |i|
      user.books.create!(
        title: "Completed Book #{i + 1}",
        start_date: (i + 2).weeks.ago,
        finish_date: (i + 1).weeks.ago,
        authors: [ author ]
      )
    end

    # Create a book in progress (this will be the 3rd book to reach the goal)
    book = user.books.create!(
      title: "Goal Reaching Book",
      start_date: 1.week.ago,
      finish_date: nil,
      authors: [ author ]
    )

    visit root_path
    assert_text "Mark as complete"

    # Mark the book as complete to reach the goal
    click_on "Mark as complete"

    # Check that goal achievement modal appears
    assert_text "Amazing Achievement!", wait: 5
    assert_text "You've reached your reading goal", wait: 2
    assert_text "3 books", wait: 2
    assert_text "Goal Reaching Book"
    assert_text "by Test Author"

    # Check for trophy emoji (goal achievement indicator)
    assert_selector "div[class*='animate-bounce']", text: "🏆", wait: 2
  end
end
