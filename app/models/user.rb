class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :authors, through: :books

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def earliest_in_progress = books.merge(Book.in_progress).order(start_date: :asc).first
  def in_progress_books = books.merge(Book.in_progress)
  def completed_books = books.merge(Book.completed)
  def completed_prior_to_this_month = completed_books.where("finish_date < ?", Time.current.beginning_of_month)

  def completed_per_month
    month_counts = completed_books
      .group_by { |b| b.finish_date.beginning_of_month }
      .transform_values(&:count)
    month_counts.values.sum / month_counts.size.to_f
  end

  def in_progress_or_recently_completed = in_progress_books.or(recently_completed)
  def recently_completed = books.merge(Book.recently_completed)
  def books_per_year_goal = 100

  def completed_books_count
    Rails.cache.fetch([ self, :completed_books_count ]) do
      completed_books.count
    end
  end
end
