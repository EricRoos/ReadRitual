require "application_system_test_case"

class AuthorsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)

    # Clean up existing data
    Book.destroy_all
    Author.destroy_all

    # Create test authors
    @author1 = Author.create!(name: "Jane Smith")
    @author2 = Author.create!(name: "John Doe")
    @author3 = Author.create!(name: "Alice Johnson")
  end

  test "displays authors page with no books" do
    visit "/authors"

    assert_selector "h1", text: "Authors"
    assert_text "No authors found."
  end

  test "displays single author with one book" do
    book = Book.create!(
      user: @user,
      title: "Solo Adventure",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    visit "/authors"

    assert_selector "h1", text: "Authors"
    assert_text "Jane Smith"

    # Click to expand the author details
    find("summary", text: "Jane Smith").click

    # Should show the book in the expanded section
    assert_text "Solo Adventure"
  end

  test "displays multiple authors with individual books" do
    book1 = Book.create!(
      user: @user,
      title: "First Book",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Second Book",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    visit "/authors"

    # Should show both authors
    assert_text "Jane Smith"
    assert_text "John Doe"

    # Expand first author
    find("summary", text: "Jane Smith").click
    assert_text "First Book"

    # Expand second author
    find("summary", text: "John Doe").click
    assert_text "Second Book"
  end

  test "displays collaborative authors correctly" do
    # Create a book with multiple authors
    collab_book = Book.create!(
      user: @user,
      title: "Joint Venture",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    visit "/authors"

    # Should show the collaboration as one entry
    assert_text "Jane Smith, John Doe"

    # Expand the collaboration
    find("summary", text: "Jane Smith, John Doe").click
    assert_text "Joint Venture"
  end

  test "displays mixed individual and collaborative works" do
    # Individual books
    Book.create!(
      user: @user,
      title: "Jane's Solo Work",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    Book.create!(
      user: @user,
      title: "John's Solo Work",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    # Collaborative book
    Book.create!(
      user: @user,
      title: "Jane and John Together",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    visit "/authors"

    # Should show three separate entries
    assert_text "Jane Smith"
    assert_text "John Doe"
    assert_text "Jane Smith, John Doe"

    # Test individual works - use more specific selectors
    all("summary").find { |s| s.text.strip.start_with?("Jane Smith") && !s.text.include?(",") }.click
    assert_text "Jane's Solo Work"

    all("summary").find { |s| s.text.strip.start_with?("John Doe") && !s.text.include?(",") }.click
    assert_text "John's Solo Work"

    # Test collaborative work
    find("summary", text: /Jane Smith, John Doe/).click
    assert_text "Jane and John Together"
  end

  test "displays same author pair with multiple collaborative books" do
    # Multiple books by the same author pair
    book1 = Book.create!(
      user: @user,
      title: "First Collaboration",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Second Collaboration",
      start_date: Date.current,
      authors: [ @author1, @author2 ]
    )

    visit "/authors"

    # Should show only one entry for the author pair
    assert_text "Jane Smith, John Doe"

    # Expand to see both books
    find("summary", text: "Jane Smith, John Doe").click
    assert_text "First Collaboration"
    assert_text "Second Collaboration"
  end

  test "displays authors sorted alphabetically" do
    # Create books to ensure authors appear in a specific order
    Book.create!(
      user: @user,
      title: "Zebra Book",
      start_date: Date.current,
      authors: [ @author3 ] # Alice Johnson
    )

    Book.create!(
      user: @user,
      title: "Alpha Book",
      start_date: Date.current,
      authors: [ @author1 ] # Jane Smith
    )

    Book.create!(
      user: @user,
      title: "Beta Book",
      start_date: Date.current,
      authors: [ @author2 ] # John Doe
    )

    visit "/authors"

    # Get the author names from the first span in each summary (excluding the arrow span)
    author_entries = all("summary span:first-child").map(&:text)

    # Should be sorted alphabetically (Alice, Jane, John)
    assert_equal [ "Alice Johnson", "Jane Smith", "John Doe" ], author_entries
  end

  test "handles three-author collaboration" do
    three_author_book = Book.create!(
      user: @user,
      title: "Triple Threat",
      start_date: Date.current,
      authors: [ @author1, @author2, @author3 ]
    )

    visit "/authors"

    # Should show all three authors together
    assert_text "Jane Smith, John Doe, Alice Johnson"

    # Expand to see the book
    find("summary", text: "Jane Smith, John Doe, Alice Johnson").click
    assert_text "Triple Threat"
  end

  test "page structure and styling elements are present" do
    Book.create!(
      user: @user,
      title: "Test Book",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    visit "/authors"

    # Check main structure
    assert_selector "h1", text: "Authors"
    assert_selector "details.group"
    assert_selector "summary"

    # Check for dropdown arrow
    assert_selector "summary span", text: "▼"

    # Test that details can be expanded
    details = find("details")
    summary = find("summary")

    # Click to open
    summary.click

    # After clicking, the content should be visible
    assert_text "Test Book"
  end

  test "shows no authors message when user has no books" do
    # Don't create any books for this user
    visit "/authors"

    assert_selector "h1", text: "Authors"
    assert_text "No authors found."
    assert_no_selector "details"
  end

  test "only shows current user's authors" do
    other_user = users(:two)

    # Create a book for the current user
    Book.create!(
      user: @user,
      title: "My Book",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    # Create a book for another user
    Book.create!(
      user: other_user,
      title: "Other User's Book",
      start_date: Date.current,
      authors: [ @author2 ]
    )

    visit "/authors"

    # Should only see the current user's author
    assert_text "Jane Smith"
    assert_no_text "John Doe"

    find("summary", text: "Jane Smith").click
    assert_text "My Book"
    assert_no_text "Other User's Book"
  end
end
