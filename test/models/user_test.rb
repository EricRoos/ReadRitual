require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "average_days_to_complete returns 0 when no completed books" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    assert_equal 0, user.average_days_to_complete
  end

  test "average_days_to_complete calculates correct average for completed books" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create completed books with different reading durations
    # Book 1: 10 days to complete
    Book.create!(
      user: user,
      title: "Book 1",
      start_date: Date.new(2024, 1, 1),
      finish_date: Date.new(2024, 1, 11),
      authors: [ author ]
    )

    # Book 2: 20 days to complete
    Book.create!(
      user: user,
      title: "Book 2",
      start_date: Date.new(2024, 2, 1),
      finish_date: Date.new(2024, 2, 21),
      authors: [ author ]
    )

    # Average should be (10 + 20) / 2 = 15 days
    assert_equal 15.0, user.average_days_to_complete
  end

  test "average_days_to_complete ignores in-progress books" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create one completed book (5 days) and one in-progress book
    Book.create!(
      user: user,
      title: "Completed Book",
      start_date: Date.new(2024, 1, 1),
      finish_date: Date.new(2024, 1, 6),
      authors: [ author ]
    )

    Book.create!(
      user: user,
      title: "In Progress Book",
      start_date: Date.new(2024, 2, 1),
      finish_date: nil, # in progress
      authors: [ author ]
    )

    # Should only consider the completed book
    assert_equal 5.0, user.average_days_to_complete
  end
end
