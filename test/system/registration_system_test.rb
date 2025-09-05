require "application_system_test_case"

class RegistrationSystemTest < ApplicationSystemTestCase
  test "user can register with valid information" do
    visit new_registration_path

    assert_text "Create account"
    assert_text "Join ReadRitual to start tracking your reading journey!"

    fill_in "Email Address", with: "newuser@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm Password", with: "password123"
    fill_in "Yearly Reading Goal", with: "50"

    click_button "Create account"

    # Should be redirected to the dashboard after successful registration
    assert_current_path root_path
    assert_text "Welcome to ReadRitual! Your account has been created."

    # User should be logged in and have correct goal
    user = User.find_by(email_address: "newuser@example.com")
    assert user
    assert_equal 50, user.books_per_year_goal
  end

  test "sign in page links to registration" do
    visit new_session_path

    assert_text "Don't have an account?"
    click_link "Sign up"

    assert_current_path new_registration_path
    assert_text "Create account"
  end

  test "registration page links back to sign in" do
    visit new_registration_path

    assert_text "Already have an account?"
    click_link "Sign in"

    assert_current_path new_session_path
    assert_text "Sign in"
  end
end
