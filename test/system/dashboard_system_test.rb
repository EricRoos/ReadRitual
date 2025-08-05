require "application_system_test_case"

class DashboardSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "dashboard displays welcome message and main actions" do
    visit root_path

    assert_selector "h2", text: "Currently reading"
    assert_selector "h2", text: "Your current goal"
  end

  test "dashboard shows in-progress book when user has one" do
    # Create an in-progress book for the user
    book = Book.create!(
      user: @user,
      title: "Currently Reading Book",
      start_date: 1.week.ago,
      authors: [ Author.create!(name: "Current Author") ]
    )

    visit root_path

    assert_text "Currently Reading Book"
    assert_text "Current Author"
    assert_button "Mark as complete"
  end

  test "dashboard shows 'Start a New Book' when no books in progress" do
    # Make sure user has no in-progress books
    @user.books.update_all(finish_date: Date.current)

    visit root_path

    assert_text "Start a New Book"
    assert_text "You currently have no books in progress"
    assert_link "Add a Book"
  end

  test "marking book as complete from dashboard" do
    # Create an in-progress book
    book = Book.create!(
      user: @user,
      title: "Book to Complete",
      start_date: 1.week.ago,
      authors: [ Author.create!(name: "Test Author") ]
    )

    visit root_path

    assert_text "Book to Complete"
    click_button "Mark as complete"

    # Should show success message and update the dashboard
    assert_text "You've completed"

    # The book should no longer appear in the currently reading section
    # and should show "Start a New Book" instead
    visit root_path
    assert_text "Start a New Book"
  end

  test "adding a book from dashboard" do
    visit root_path

    # Click the "Add a Book" link
    click_link "Add a Book"

    # Should be on new book path (may include return_to parameter)
    assert_current_path(/\/books\/new/)
    assert_selector "h2", text: "Add from Audible"
  end

  test "dashboard shows reading goals and progress" do
    visit root_path

    assert_selector "section.goals-overview"
    assert_text "Your current goal"

    # Should show some kind of progress indicator
    # Adjust based on your actual implementation
  end

  test "dashboard shows recently completed books" do
    # Create a recently completed book
    completed_book = Book.create!(
      user: @user,
      title: "Recently Completed",
      start_date: 2.weeks.ago,
      finish_date: 1.day.ago,
      authors: [ Author.create!(name: "Completed Author") ]
    )

    visit root_path

    # Should show recently completed books section
    # Adjust selectors based on your actual implementation
    assert_text "Recently Completed"
  end

  test "navigation from dashboard to books index" do
    visit root_path

    # Look for navigation to books - adjust based on your nav structure
    within "nav, .navigation, header" do
      click_link "Books"
    end

    assert_current_path books_path
  end

  test "navigation from dashboard to authors index" do
    visit root_path

    # Look for navigation to authors - adjust based on your nav structure
    within "nav, .navigation, header" do
      click_link "Authors"
    end

    assert_current_path authors_path
  end

  test "dashboard responsive design elements" do
    visit root_path

    # Test that key responsive elements are present
    assert_selector ".grid" # Grid layout
    assert_selector ".md\\:grid-cols-2, .sm\\:grid-cols-2" # Responsive grid
  end

  test "dashboard caching works correctly" do
    visit root_path

    # Verify page loads successfully
    assert_text "Currently reading"

    # Create a new book
    Book.create!(
      user: @user,
      title: "New Book After Cache",
      start_date: Date.current,
      authors: [ Author.create!(name: "New Author") ]
    )

    # Refresh the page - content should update
    visit root_path
    assert_text "New Book After Cache"
  end

  test "dashboard handles user with no books" do
    # Remove all books for the user
    @user.books.destroy_all

    visit root_path

    assert_text "Start a New Book"
    assert_text "You currently have no books in progress"

    # Should still show goals section
    assert_text "Your current goal"
  end
end
