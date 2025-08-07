require "application_system_test_case"

class AuthorsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)

    # Clean up existing data
    Book.includes(:user).destroy_all
    Author.destroy_all

    # Create test authors
    @author1 = Author.create!(name: "Jane Smith")
    @author2 = Author.create!(name: "John Doe")
    @author3 = Author.create!(name: "Alice Johnson")
  end

  test "displays authors page with no books" do
    visit "/authors"

    assert_text "Your reading authors"
    assert_text "Add your first book"
  end

  test "displays single author with one book" do
    book = Book.create!(
      user: @user,
      title: "Solo Adventure",
      start_date: Date.current,
      authors: [ @author1 ]
    )

    visit "/authors"

    assert_text "Your reading authors"
    click_author_details("Jane Smith")
    assert_text "Jane Smith"
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
    click_author_details("Jane Smith")
    assert_text "First Book"

    # Expand second author
    click_author_details("John Doe")
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
    click_author_details("Jane Smith, John Doe")
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

    # Test individual works - use simpler approach for solo authors
    # Assuming the implementation shows separate entries for solo vs collaborative works
    click_author_details("Jane Smith")
    assert_text "Jane's Solo Work"

    click_author_details("John Doe")
    assert_text "John's Solo Work"

    # Test collaborative work - find the collaborative summary
    click_author_details("Jane Smith, John Doe")
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
    click_author_details("Jane Smith, John Doe")
    assert_text "First Collaboration"
    assert_text "Second Collaboration"
  end

  test "handles three-author collaboration" do
    three_author_book = Book.create!(
      user: @user,
      title: "Triple Threat",
      start_date: Date.current,
      authors: [ @author1, @author2, @author3 ]
    )

    visit "/authors"
    assert_text "Jane Smith, John Doe, Alice Johnson"
    click_author_details("Jane Smith, John Doe, Alice Johnson")
    assert_text "Triple Threat"
  end

  test "shows no authors message when user has no books" do
    # Don't create any books for this user
    visit "/authors"

    assert_text "Your reading authors"
    assert_text "Add your first book"
    # Verify there are no author sections to expand
    assert_no_text "solo"
    assert_no_text "collaboration"
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

    click_author_details("Jane Smith")
    assert_text "My Book"
    assert_no_text "Other User's Book"
  end
end
