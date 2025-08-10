class SandboxController < ApplicationController
  def index
    @books_read = Current.user.completed_books_count
    @books_goal = Current.user.books_per_year_goal
    @average_days_to_complete = Current.user.average_days_to_complete
    @recently_completed = Current.user.recently_completed.includes(:authors).with_attached_cover_image
    @show_estimated_completion = Flipper.enabled?(:show_estimated_completion, Current.user)
    fresh_when Current.user
  end
end
