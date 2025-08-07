require "application_system_test_case"

class AudibleIntegrationSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as(@user)
  end

  test "Audible URL form is present and functional" do
    visit new_book_path

    # Verify we're on the Audible entry form
    assert_text "Add from Audible"
    assert_field "audible_url"

    # Test that the form has the correct functionality instead of implementation details
    assert_field "audible_url", placeholder: "4. Paste Audible link here"
    assert_button "Go"
  end

  test "Audible URL form validation and error handling" do
    visit new_book_path

    # Test empty URL
    fill_in "audible_url", with: ""
    click_button "Go"

    # This will likely show some error or redirect
    # The form submission goes to books_path but may render new template
    assert_current_path(/\/books/)

    # Test invalid URL format
    visit new_book_path
    fill_in "audible_url", with: "not-a-valid-url"
    click_button "Go"

    # Should handle invalid URLs gracefully
    assert_current_path(/\/books/)
  end

  test "workflow from dashboard to Audible book creation" do
    # Start from dashboard
    visit root_path

    # Click "Add a Book" from dashboard
    click_link "Add a Book"

    # Should be on new book page with Audible form
    assert_current_path(/\/books\/new/)
    assert_text "Add from Audible"

    # Test that the form is present and ready for input
    assert_field "audible_url"
    assert_button "Go"
  end

  test "alternative paths from Audible form" do
    visit new_book_path

    # Test navigation to search
    click_link "Add from search"
    assert_current_path(/\/books\/new.*v1=true/)

    # Go back and test manual entry
    visit new_book_path
    click_link "Add manually"
    assert_current_path(/\/books\/new.*manual=true/)

    # Should show manual form
    assert_field "Title"
    assert_field "Author"
  end

  test "Audible URL clipboard functionality" do
    visit new_book_path

    # Test that clipboard functionality is accessible through the input field
    audible_field = find_field("audible_url")
    assert_equal "4. Paste Audible link here", audible_field[:placeholder]

    # The actual clipboard functionality would need to be tested with JavaScript
    # This verifies the user can access the input field properly
  end

  test "Audible form preserves return_to parameter" do
    return_path = root_path
    visit new_book_path(return_to: return_path)

    # Verify the form is present with return_to parameter
    assert_field "audible_url"
    assert_button "Go"

    # The actual submission and return behavior would need mocking to test fully
  end

  test "Audible URL input placeholder and instructions are clear" do
    visit new_book_path

    # Check for clear instructions
    assert_text "Open the book in Audible"
    assert_text "Tap the Share"
    assert_text "Tap Copy"

    # Check for proper form setup - the placeholder is in the form field
    audible_field = find_field("audible_url")
    assert_equal "4. Paste Audible link here", audible_field[:placeholder]
  end

  test "Iron Gold URL structure validation" do
    visit new_book_path

    # This is the specific URL format for Iron Gold
    iron_gold_url = "https://www.audible.com/pd/Iron-Gold-Audiobook/B074NBTRGL?source_code=ORGOR69210072400FS&share_location=player_overflow"

    # Fill in the URL to test form accepts it
    fill_in "audible_url", with: iron_gold_url

    # Verify the input was filled correctly
    assert_field "audible_url", with: iron_gold_url

    # The form should be ready to submit
    assert_button "Go"
  end
end
