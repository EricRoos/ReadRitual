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
end
