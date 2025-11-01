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

  test "completed_books_this_year_count returns 0 when no books completed this year" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    assert_equal 0, user.completed_books_this_year_count
  end

  test "completed_books_this_year_count only counts books completed in current year" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create books completed in different years
    # Book from last year
    Book.create!(
      user: user,
      title: "Last Year Book",
      start_date: Date.new(2024, 11, 1),
      finish_date: Date.new(2024, 12, 15),
      authors: [ author ]
    )

    # Books from this year
    Book.create!(
      user: user,
      title: "This Year Book 1",
      start_date: Date.new(2025, 1, 1),
      finish_date: Date.new(2025, 1, 15),
      authors: [ author ]
    )

    Book.create!(
      user: user,
      title: "This Year Book 2",
      start_date: Date.new(2025, 2, 1),
      finish_date: Date.new(2025, 2, 20),
      authors: [ author ]
    )

    # Travel to 2025 to test
    travel_to Date.new(2025, 6, 1) do
      # Should only count the 2 books from 2025
      assert_equal 2, user.completed_books_this_year_count
      # But total completed books count should still be 3
      assert_equal 3, user.completed_books_count
    end
  end

  test "completed_books_this_year_count ignores in-progress books" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create completed and in-progress books
    Book.create!(
      user: user,
      title: "Completed This Year",
      start_date: Date.new(2025, 1, 1),
      finish_date: Date.new(2025, 1, 15),
      authors: [ author ]
    )

    Book.create!(
      user: user,
      title: "In Progress",
      start_date: Date.new(2025, 2, 1),
      finish_date: nil,
      authors: [ author ]
    )

    travel_to Date.new(2025, 6, 1) do
      # Should only count completed books from this year
      assert_equal 1, user.completed_books_this_year_count
    end
  end

  test "books_left_in_goal uses current year count" do
    user = User.create!(email_address: "test@example.com", password: "password123", books_per_year_goal: 10)
    author = Author.create!(name: "Test Author")

    # Create books from last year
    3.times do |i|
      Book.create!(
        user: user,
        title: "Last Year Book #{i}",
        start_date: Date.new(2024, 1, 1),
        finish_date: Date.new(2024, 1, 15),
        authors: [ author ]
      )
    end

    # Create books from this year
    2.times do |i|
      Book.create!(
        user: user,
        title: "This Year Book #{i}",
        start_date: Date.new(2025, 1, 1),
        finish_date: Date.new(2025, 1, 15),
        authors: [ author ]
      )
    end

    travel_to Date.new(2025, 6, 1) do
      # Goal is 10, completed this year is 2, so 8 books left
      assert_equal 8, user.send(:books_left_in_goal)
    end
  end

  test "completed_books_this_year_count updates when year changes" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    author = Author.create!(name: "Test Author")

    # Create a book in 2024
    Book.create!(
      user: user,
      title: "2024 Book",
      start_date: Date.new(2024, 1, 1),
      finish_date: Date.new(2024, 12, 31),
      authors: [ author ]
    )

    # In 2024, count should be 1
    travel_to Date.new(2024, 12, 31) do
      assert_equal 1, user.completed_books_this_year_count
    end

    # In 2025, count should be 0 (new year reset)
    travel_to Date.new(2025, 1, 1) do
      assert_equal 0, user.completed_books_this_year_count
    end

    # Add a book in 2025
    Book.create!(
      user: user,
      title: "2025 Book",
      start_date: Date.new(2025, 1, 1),
      finish_date: Date.new(2025, 1, 15),
      authors: [ author ]
    )

    # In 2025, count should now be 1
    travel_to Date.new(2025, 1, 15) do
      assert_equal 1, user.completed_books_this_year_count
    end
  end
end
