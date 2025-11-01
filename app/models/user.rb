class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :authors, through: :books

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :books_per_year_goal, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 1000 }

  def earliest_in_progress = books.includes(:authors).merge(Book.in_progress).order(start_date: :asc).first
  def in_progress_books = books.merge(Book.in_progress)
  def completed_books = books.merge(Book.completed)

  def completed_per_month(time_range = Date.current.beginning_of_year..Date.current)
    books_in_range = completed_books.where(finish_date: time_range)
    return 0 if books_in_range.empty?

    months = books_in_range.map { |b| b.finish_date.beginning_of_month }.uniq.size
    books_in_range.size / months.to_f
  end

  def completed_per_day
    completed_per_month / 30
  end

  def in_progress_books_count = in_progress_books.count

  def in_progress_or_recently_completed = in_progress_books.or(recently_completed)
  def recently_completed = books.merge(Book.recently_completed)
  def books_per_year_goal
    self[:books_per_year_goal] || 100
  end

  def estimated_completion_date
    return nil if books_left_in_goal <= 0
    days_to_finish = books_left_in_goal / completed_per_day
    Date.current + days_to_finish.days
  end

  # Cached version of completed_books_count (all time)
  def completed_books_count
    Rails.cache.fetch([ self, :completed_books_count ]) do
      completed_books.count
    end
  end

  # Returns count of books completed in the current year only
  # Used for tracking progress towards the yearly reading goal
  def completed_books_this_year_count
    Rails.cache.fetch([ self, :completed_books_this_year_count, Date.current.year ]) do
      completed_books.where(finish_date: Date.current.beginning_of_year..Date.current.end_of_year).count
    end
  end

  def average_days_to_complete
    Rails.cache.fetch([ self, :average_days_to_complete ]) do
      result = completed_books.pluck(
        Arel.sql("finish_date - start_date")
      ).map(&:to_f).sum

      count = completed_books.count
      count > 0 ? (result / count).round(1) : 0
    end
  end

  def average_duration_minutes
    Rails.cache.fetch([ self, :average_duration_minutes ]) do
      books_with_duration = completed_books.where.not(duration_minutes: nil)
      return 0 if books_with_duration.empty?

      total_minutes = books_with_duration.sum(:duration_minutes)
      count = books_with_duration.count
      (total_minutes.to_f / count).round(0)
    end
  end

  protected

  def books_left_in_goal
    books_per_year_goal - completed_books_this_year_count
  end
end
