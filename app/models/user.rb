class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :authors, through: :books

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def earliest_in_progress = books.merge(Book.in_progress).order(start_date: :asc).first
  def in_progress_books = books.merge(Book.in_progress)
  def completed_books = books.merge(Book.completed)

  def completed_per_month
    month_counts = completed_books
      .group_by { |b| b.finish_date.beginning_of_month }
      .transform_values(&:count)
    month_counts.values.sum / month_counts.size.to_f
  end

  def completed_per_day
    return 0 if completed_books_count.zero?
    completed_books_count / (Date.current - completed_books.minimum(:start_date))
  end


  def in_progress_books_count = in_progress_books.count
  def completed_books_count = completed_books.count

  def in_progress_or_recently_completed = in_progress_books.or(recently_completed)
  def recently_completed = books.merge(Book.recently_completed)
  def books_per_year_goal = 100

  def estimated_completion_date
    return nil if books_left_in_goal <= 0
    days_to_finish = books_left_in_goal / completed_per_day
    Date.current + days_to_finish.days
  end

  def completed_books_count
    Rails.cache.fetch([ self, :completed_books_count ]) do
      completed_books.count
    end
  end

  protected

  def books_left_in_goal
    books_per_year_goal - completed_books_count
  end
end
