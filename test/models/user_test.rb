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

  test "average_duration_minutes returns 0 when no completed books" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    assert_equal 0, user.average_duration_minutes
  end

  test "average_duration_minutes returns 0 when no books have duration_minutes" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create completed book without duration_minutes
    Book.create!(
      user: user,
      title: "Book without duration",
      start_date: Date.new(2024, 1, 1),
      finish_date: Date.new(2024, 1, 11),
      authors: [ author ]
    )

    assert_equal 0, user.average_duration_minutes
  end

  test "average_duration_minutes calculates correct average for books with duration" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create completed books with duration_minutes
    # Book 1: 300 minutes (5 hours)
    Book.create!(
      user: user,
      title: "Book 1",
      start_date: Date.new(2024, 1, 1),
      finish_date: Date.new(2024, 1, 11),
      duration_minutes: 300,
      authors: [ author ]
    )

    # Book 2: 600 minutes (10 hours)
    Book.create!(
      user: user,
      title: "Book 2",
      start_date: Date.new(2024, 2, 1),
      finish_date: Date.new(2024, 2, 21),
      duration_minutes: 600,
      authors: [ author ]
    )

    # Average should be (300 + 600) / 2 = 450 minutes
    assert_equal 450, user.average_duration_minutes
  end

  test "average_duration_minutes ignores books without duration_minutes" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create one book with duration and one without
    Book.create!(
      user: user,
      title: "Book with duration",
      start_date: Date.new(2024, 1, 1),
      finish_date: Date.new(2024, 1, 11),
      duration_minutes: 400,
      authors: [ author ]
    )

    Book.create!(
      user: user,
      title: "Book without duration",
      start_date: Date.new(2024, 2, 1),
      finish_date: Date.new(2024, 2, 11),
      authors: [ author ]
    )

    # Should only consider the book with duration
    assert_equal 400, user.average_duration_minutes
  end

  test "average_duration_minutes ignores in-progress books" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create one completed book with duration and one in-progress with duration
    Book.create!(
      user: user,
      title: "Completed Book",
      start_date: Date.new(2024, 1, 1),
      finish_date: Date.new(2024, 1, 6),
      duration_minutes: 300,
      authors: [ author ]
    )

    Book.create!(
      user: user,
      title: "In Progress Book",
      start_date: Date.new(2024, 2, 1),
      finish_date: nil, # in progress
      duration_minutes: 500,
      authors: [ author ]
    )

    # Should only consider the completed book
    assert_equal 300, user.average_duration_minutes
  end
end
