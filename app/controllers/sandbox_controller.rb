class SandboxController < ApplicationController
  def index
    @in_progress_book = Current.user.earliest_in_progress
    @books_read = Current.user.completed_books.count
    @books_goal = Current.user.books_per_year_goal
    @recently_completed = Current.user.recently_completed
  end
end
