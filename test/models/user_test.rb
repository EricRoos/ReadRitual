require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user can be created with valid attributes" do
    user = User.new(email_address: "test@example.com", password: "password123")
    assert user.valid?
  end

  test "user email is normalized" do
    user = User.create!(email_address: "Test@Example.COM  ", password: "password123")
    assert_equal "test@example.com", user.email_address
  end

  test "user has books per year goal" do
    user = User.new
    assert_equal 100, user.books_per_year_goal
  end
end
