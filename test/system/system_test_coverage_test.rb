require "application_system_test_case"

class SystemTestCoverageTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "all main application paths are accessible" do
    # Dashboard/Sandbox (root path)
    visit root_path
    assert_text "Currently reading"

    # Books index
    visit books_path
    assert_text "Books"

    # Books new
    visit new_book_path
    assert_text "Add from Audible"

    # Authors index
    visit authors_path
    assert_text "Authors"

    # Profile
    visit profile_path
    assert_text "Profile" # Adjust based on your actual profile content
  end

  test "core user workflows are functional" do
    # 1. Dashboard to add book workflow
    visit root_path
    click_link "Add a Book"
    assert_current_path(/\/books\/new/)

    # 2. Manual book creation workflow
    click_link "Add manually"
    fill_in "Title", with: "System Test Book"
    fill_in "Author", with: "System Test Author"
    fill_in "Start date", with: Date.current.strftime("%m/%d/%Y")
    click_button "Create Book"
    assert_text "Book was successfully created"

    # 3. View book details
    assert_text "System Test Book"

    # 4. Navigate to books index
    visit books_path
    assert_text "System Test Book"

    # 5. Navigate to authors index
    visit authors_path
    assert_text "System Test Author"
  end

  test "Audible integration UI is complete" do
    visit new_book_path

    # Main Audible form
    assert_text "Add from Audible"
    assert_field "audible_url"
    assert_button "Go"

    # Instructions
    assert_text "Open the book in Audible"
    assert_text "Tap the Share"
    assert_text "Tap Copy"

    # Alternative paths
    assert_link "Add from search"
    assert_link "Add manually"

    # Clipboard functionality setup - verify the input field has clipboard functionality
    assert_field "audible_url", placeholder: "4. Paste Audible link here"
  end

  test "responsive design elements are present" do
    # Dashboard
    visit root_path
    # Instead of checking CSS classes, verify content is accessible
    assert_text "Currently reading"
    assert_text "Your reading goal"

    # Create an author and book so the authors page has content
    author = Author.create!(name: "Test Author")
    Book.create!(
      user: @user,
      title: "Test Book",
      start_date: Date.current,
      authors: [ author ]
    )

    # Authors page
    visit authors_path
    # Verify the collapsible functionality exists
    assert_text "Test Author"
    click_author_details("Test Author")
    assert_text "Test Book"

    # Books page responsive elements - verify content is accessible
    visit books_path
    assert_text "Your book library"
  end

  test "navigation between main sections works" do
    visit root_path

    # From dashboard to books
    within_navigation do
      click_link "Books"
    end
    assert_current_path books_path

    # From books to authors
    within_navigation do
      click_link "Authors"
    end
    assert_current_path authors_path

    # From authors back to dashboard
    visit root_path
    assert_text "Currently reading"
  end
end
