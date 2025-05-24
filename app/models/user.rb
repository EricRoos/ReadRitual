class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :books, dependent: :destroy
  has_many :authors, through: :books

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def earliest_in_progress = books.merge(Book.in_progress).order(start_date: :asc).first
  def in_progress_books = books.merge(Book.in_progress)
  def completed_books = books.merge(Book.completed)
  def recently_completed = books.merge(Book.recently_completed)
  def books_per_year_goal = 100
end
