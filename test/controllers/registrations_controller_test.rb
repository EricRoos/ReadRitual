require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url
    assert_response :success
    assert_select "h1", "Create account"
  end

  test "should create user with valid data" do
    assert_difference("User.count") do
      post registrations_url, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          books_per_year_goal: 50
        }
      }
    end

    user = User.find_by(email_address: "newuser@example.com")
    assert user
    assert_equal 50, user.books_per_year_goal
    assert_redirected_to root_url
  end

  test "should not create user with invalid data" do
    assert_no_difference("User.count") do
      post registrations_url, params: {
        user: {
          email_address: "",
          password: "password123",
          password_confirmation: "different",
          books_per_year_goal: 50
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should not create user with duplicate email" do
    existing_user = users(:one)

    assert_no_difference("User.count") do
      post registrations_url, params: {
        user: {
          email_address: existing_user.email_address,
          password: "password123",
          password_confirmation: "password123",
          books_per_year_goal: 50
        }
      }
    end

    assert_response :unprocessable_content
  end
end
