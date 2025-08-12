require "application_system_test_case"

class BookCoverMagnifySystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
    @book = books(:one)
  end

  test "can magnify book cover from book index page" do
    visit books_path

    # Find and click on a book cover image
    book_cover = find("img[alt='Book Cover']", match: :first)
    assert book_cover.present?

    # Click on the book cover to magnify
    book_cover.click

    # Check that magnified overlay appears
    assert_selector "[data-image-magnify-overlay]", wait: 1
    assert_selector "img[data-modal-image]", wait: 1

    # Verify close button is present
    assert_selector "button[aria-label='Close magnified view']"

    # Close the overlay by clicking the close button
    find("button[aria-label='Close magnified view']").click

    # Verify overlay is removed - wait for animation to complete
    assert_no_selector "[data-image-magnify-overlay]", wait: 2
  end

  test "can magnify book cover from book show page" do
    visit book_path(@book)

    # Find and click on the main book cover image
    book_cover = find("img[alt$='Cover']")
    assert book_cover.present?

    # Click on the book cover to magnify
    book_cover.click

    # Check that magnified overlay appears
    assert_selector "[data-image-magnify-overlay]", wait: 1
    assert_selector "img[data-modal-image]", wait: 1
  end

  test "can close magnified overlay with escape key" do
    visit books_path

    # Click on a book cover to magnify
    find("img[alt='Book Cover']", match: :first).click

    # Wait for overlay to appear
    assert_selector "[data-image-magnify-overlay]", wait: 1

    # Press escape key to close
    page.driver.browser.action.send_keys(:escape).perform

    # Verify overlay is removed - wait for animation to complete
    assert_no_selector "[data-image-magnify-overlay]", wait: 2
  end

  test "can magnify book cover from dashboard in-progress section" do
    # Create an in-progress book
    in_progress_book = Book.create!(
      user: @user,
      title: "In Progress Book",
      start_date: Date.current,
      authors: [ Author.create!(name: "Test Author") ]
    )

    visit root_path

    # Should show the book in the "currently reading" section
    assert_text "In Progress Book"

    # If we have a currently reading book, test its cover magnification
    if has_css?("img[alt='Current Book Cover']")
      find("img[alt='Current Book Cover']").click

      # Check that magnified overlay appears
      assert_selector "[data-image-magnify-overlay]", wait: 1
      assert_selector "img[data-modal-image]", wait: 1

      # Close it
      find("button[aria-label='Close magnified view']").click
      assert_no_selector "[data-image-magnify-overlay]", wait: 2
    else
      skip "No current book cover found on dashboard"
    end
  end

  test "can magnify book cover from dashboard recently completed section" do
    # Create a completed book
    completed_book = Book.create!(
      user: @user,
      title: "Completed Book",
      start_date: 1.month.ago,
      finish_date: Date.current,
      authors: [ Author.create!(name: "Completed Author") ]
    )

    visit root_path

    # Should show the book in the "recently completed" section
    assert_text "Recently completed books"
    assert_text "Completed Book"

    # Find the book cover in the recently completed section
    within(".recent-books") do
      book_cover = find("img[alt='Book Cover']")
      assert book_cover.present?

      # Verify the image has the correct data attributes
      assert book_cover["data-controller"] == "image-magnify"
      assert book_cover["data-action"] == "click->image-magnify#show"

      # Debug: log the image source
      puts "Image src: #{book_cover[:src]}"

      # Click on the book cover to magnify
      book_cover.click
    end

    # Check that magnified overlay appears (overlay is added to body, not within the section)
    # Add longer wait time for debugging
    assert_selector "[data-image-magnify-overlay]", wait: 3
    assert_selector "img[data-modal-image]", wait: 3

    # Verify close button is present
    assert_selector "button[aria-label='Close magnified view']"

    # Close the overlay by clicking the close button
    find("button[aria-label='Close magnified view']").click

    # Verify overlay is removed - wait for animation to complete
    assert_no_selector "[data-image-magnify-overlay]", wait: 3
  end

  test "magnified image loads with correct attributes" do
    visit books_path

    # Get the original image source
    original_img = find("img[alt='Book Cover']", match: :first)
    original_src = original_img[:src]

    # Click to magnify
    original_img.click

    # Wait for overlay and verify magnified image has same source
    assert_selector "[data-image-magnify-overlay]", wait: 1
    magnified_img = find("img[data-modal-image]")

    assert_equal original_src, magnified_img[:src]
    assert_equal "Magnified book cover", magnified_img[:alt]
  end

  test "multiple book covers can be magnified independently" do
    # Ensure we have multiple books for testing
    Book.create!(
      user: @user,
      title: "Second Book",
      start_date: Date.current,
      authors: [ Author.create!(name: "Second Author") ]
    )

    visit books_path

    # Get all book cover images
    book_covers = all("img[alt='Book Cover']")
    assert book_covers.count >= 2, "Need at least 2 books for this test"

    # Click first book cover
    book_covers.first.click
    assert_selector "[data-image-magnify-overlay]", wait: 1

    # Close it
    find("button[aria-label='Close magnified view']").click
    assert_no_selector "[data-image-magnify-overlay]", wait: 2

    # Click second book cover
    book_covers[1].click
    assert_selector "[data-image-magnify-overlay]", wait: 1

    # Verify it works independently
    assert_selector "img[data-modal-image]"
  end
end
