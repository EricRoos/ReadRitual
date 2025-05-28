class SandboxController < ApplicationController
  def index
    @books_read = Current.user.completed_books_count
    @books_goal = Current.user.books_per_year_goal
    @recently_completed = Current.user.recently_completed.includes(:authors).with_attached_cover_image
    fresh_when Current.user
  end

  protected

  def in_progress_book
    @in_progress_book ||= Current.user.earliest_in_progress
  end
  helper_method :in_progress_book
end
