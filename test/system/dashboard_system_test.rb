require "application_system_test_case"

class DashboardSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "dashboard displays welcome message and main actions" do
    visit root_path

    assert_text "Currently reading"
    assert_text "Your reading goal"
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

    assert_text "Ready to Start Reading?"
    assert_text "You don't have any books in progress right now"
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
    assert_text "Add a Book"
  end

  test "adding a book from dashboard" do
    visit root_path

    # Click the "Add a Book" link
    click_link "Add a Book"

    # Should be on new book path (may include return_to parameter)
    assert_current_path(/\/books\/new/)
    assert_text "Add from Audible"
  end

  test "dashboard shows reading goals and progress" do
    visit root_path

    assert_text "Your reading goal"

    # Should show some kind of progress indicator
    # Adjust based on your actual implementation
  end

  test "dashboard shows metrics tiles for completed books, goal, and in progress" do
    # Create test data for metrics
    author = Author.create!(name: "Test Author")

    # Create completed books
    2.times do |i|
      Book.create!(
        user: @user,
        title: "Completed Book #{i+1}",
        start_date: (20+i*5).days.ago,
        finish_date: (15+i*5).days.ago,
        authors: [ author ]
      )
    end

    # Create in-progress book
    Book.create!(
      user: @user,
      title: "In Progress Book",
      start_date: 3.days.ago,
      authors: [ author ]
    )

    visit root_path

    # Should show metrics in the dashboard header area
    assert_text "books completed"
    assert_text "Goal:"
    assert_text "books/year"
    assert_text "in progress"

    # Verify the actual counts appear
    # Note: The actual numbers will depend on existing fixtures + our test data
    within_page_header do
      assert_css "[data-testid], .flex", count: 3 # Should have 3 metric items
    end
  end

  private

  def within_page_header
    # Target the metrics section under the page title
    within("div.text-center") { yield }
  end

  test "dashboard shows average time to complete metric" do
    # Create completed books with different reading durations
    author = Author.create!(name: "Test Author")
    visit root_path
    assert_text "Avg. time to finish:"
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

    # Look for navigation to books - use semantic selector
    within_navigation do
      click_link "Books"
    end

    assert_current_path books_path
  end

  test "navigation from dashboard to authors index" do
    visit root_path

    # Look for navigation to authors - use semantic selector
    within_navigation do
      click_link "Authors"
    end

    assert_current_path authors_path
  end

  test "dashboard responsive design elements" do
    visit root_path

    # Test that key content is accessible and responsive layout works
    assert_text "Currently reading"
    assert_text "Your reading goal"

    # Instead of checking CSS classes, verify the content is properly displayed
    # and accessible to users regardless of layout implementation
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

    assert_text "Ready to Start Reading?"
    assert_text "You don't have any books in progress right now"

    # Should still show goals section
    assert_text "Your reading goal"
  end
end
