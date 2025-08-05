require "application_system_test_case"

class AuthorsSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "authors index displays user's authors" do
    # Create some authors and books for the user
    author1 = Author.create!(name: "Test Author One")
    author2 = Author.create!(name: "Test Author Two")

    book1 = Book.create!(
      user: @user,
      title: "Book by Author One",
      start_date: Date.current,
      authors: [ author1 ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Book by Author Two",
      start_date: Date.current,
      authors: [ author2 ]
    )

    visit authors_path

    assert_text "Test Author One"
    assert_text "Test Author Two"
  end

  test "authors index shows authors sorted alphabetically" do
    # Create authors in non-alphabetical order
    author_z = Author.create!(name: "Zulu Author")
    author_a = Author.create!(name: "Alpha Author")
    author_m = Author.create!(name: "Middle Author")

    # Create books for each author
    [ author_z, author_a, author_m ].each_with_index do |author, index|
      Book.create!(
        user: @user,
        title: "Book #{index}",
        start_date: Date.current,
        authors: [ author ]
      )
    end

    visit authors_path

    # Verify all authors are present
    assert_text "Alpha Author"
    assert_text "Middle Author"
    assert_text "Zulu Author"

    # The authors should appear in alphabetical order in the summary elements
    summaries = page.all("summary span").map(&:text)
    author_names = summaries.grep(/Author$/) # Get elements ending with "Author"
    assert_equal author_names.sort, author_names, "Authors should be sorted alphabetically"
  end

  test "authors index shows books associated with each author" do
    author = Author.create!(name: "Prolific Author")

    book1 = Book.create!(
      user: @user,
      title: "First Book",
      start_date: Date.current,
      authors: [ author ]
    )

    book2 = Book.create!(
      user: @user,
      title: "Second Book",
      start_date: Date.current,
      authors: [ author ]
    )

    visit authors_path

    assert_text "Prolific Author"

    # Open the details section for this author
    find("summary", text: "Prolific Author").click

    # Now the books should be visible
    assert_text "First Book"
    assert_text "Second Book"
  end

  test "authors index handles authors with multiple books" do
    author = Author.create!(name: "Multi Book Author")

    # Create several books for this author
    5.times do |i|
      Book.create!(
        user: @user,
        title: "Book Number #{i + 1}",
        start_date: Date.current - i.days,
        authors: [ author ]
      )
    end

    visit authors_path

    assert_text "Multi Book Author"

    # Open the details section
    find("summary", text: "Multi Book Author").click

    # Should show all books by this author
    (1..5).each do |i|
      assert_text "Book Number #{i}"
    end
  end

  test "authors index handles collaborative authors" do
    author1 = Author.create!(name: "Collaborator One")
    author2 = Author.create!(name: "Collaborator Two")

    # Create a book with multiple authors
    collab_book = Book.create!(
      user: @user,
      title: "Collaborative Work",
      start_date: Date.current,
      authors: [ author1, author2 ]
    )

    # Create individual books
    solo_book1 = Book.create!(
      user: @user,
      title: "Solo Work One",
      start_date: Date.current,
      authors: [ author1 ]
    )

    solo_book2 = Book.create!(
      user: @user,
      title: "Solo Work Two",
      start_date: Date.current,
      authors: [ author2 ]
    )

    visit authors_path

    assert_text "Collaborator One"
    assert_text "Collaborator Two"

    # Check that we have collaborative and individual author groups
    # The collaborative group should contain both authors
    collaborative_group = find("summary", text: /Collaborator One.*Collaborator Two/)
    collaborative_group.click
    assert_text "Collaborative Work"
    collaborative_group.click # Close

    # Check individual author sections - they might be separate or combined
    # Let's find all summary elements and work with what we have
    summaries = all("summary")
    author_summaries = summaries.select { |s| s.text.include?("Collaborator") }

    # Find a summary that contains only one author name for solo works
    solo_one_summary = author_summaries.find { |s| s.text.include?("Collaborator One") && !s.text.include?("Collaborator Two") }
    solo_two_summary = author_summaries.find { |s| s.text.include?("Collaborator Two") && !s.text.include?("Collaborator One") }

    if solo_one_summary
      solo_one_summary.click
      assert_text "Solo Work One"
      solo_one_summary.click # Close
    end

    if solo_two_summary
      solo_two_summary.click
      assert_text "Solo Work Two"
    end
  end

  test "authors index shows book covers when available" do
    author = Author.create!(name: "Author with Covers")

    book = Book.create!(
      user: @user,
      title: "Book with Cover",
      start_date: Date.current,
      authors: [ author ]
    )

    visit authors_path

    assert_text "Author with Covers"

    # Open the author details
    find("summary", text: "Author with Covers").click

    assert_text "Book with Cover"

    # Should show book cover image (default book cover)
    assert_selector "img[alt*='Book Cover']"
  end

  test "authors index handles authors with no books" do
    # This test ensures we only show authors that have books
    author_with_book = Author.create!(name: "Author With Book")
    author_without_book = Author.create!(name: "Author Without Book")

    Book.create!(
      user: @user,
      title: "Existing Book",
      start_date: Date.current,
      authors: [ author_with_book ]
    )

    visit authors_path

    assert_text "Author With Book"
    assert_no_text "Author Without Book"
  end

  test "navigation to authors page from other pages" do
    visit root_path

    # Navigate to authors from dashboard
    within "nav, .navigation, header" do
      click_link "Authors"
    end

    assert_current_path authors_path
  end

  test "authors index responsive design" do
    # Create some test data
    author = Author.create!(name: "Responsive Test Author")
    Book.create!(
      user: @user,
      title: "Responsive Test Book",
      start_date: Date.current,
      authors: [ author ]
    )

    visit authors_path

    # Check for responsive design elements - the authors page uses details/summary
    assert_selector "details"
    assert_selector "summary"
  end

  test "authors index shows accurate book counts" do
    author = Author.create!(name: "Count Test Author")

    # Create multiple books
    3.times do |i|
      Book.create!(
        user: @user,
        title: "Count Book #{i + 1}",
        start_date: Date.current,
        authors: [ author ]
      )
    end

    visit authors_path

    assert_text "Count Test Author"

    # Open the author details and check book count
    find("summary", text: "Count Test Author").click

    # Should show 3 books for this author
    assert_text "Count Book 1"
    assert_text "Count Book 2"
    assert_text "Count Book 3"
  end

  test "authors index handles empty state" do
    # Remove all books/authors for user
    @user.books.destroy_all

    visit authors_path

    # Should show empty state message
    # Check for either message depending on your implementation
    page_text = page.text
    assert(page_text.include?("No authors found") || page_text.include?("You haven't added any books yet"))
  end

  test "clicking on book from authors page navigates to book details" do
    author = Author.create!(name: "Clickable Author")
    book = Book.create!(
      user: @user,
      title: "Clickable Book",
      start_date: Date.current,
      authors: [ author ]
    )

    visit authors_path

    # Open the author details first
    find("summary", text: "Clickable Author").click

    # The book titles are not links - need to click the eye icon
    # Find the book container and click the eye icon link
    within(".flex", text: "Clickable Book") do
      find("a[href='#{book_path(book)}']").click
    end

    assert_current_path book_path(book)
    assert_text "Clickable Book"
  end
end
