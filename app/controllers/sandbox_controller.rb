class SandboxController < ApplicationController
  def index
    @books_read = Current.user.completed_books_count
    @books_goal = Current.user.books_per_year_goal
    @average_days_to_complete = Current.user.average_days_to_complete
    @average_duration_minutes = Current.user.average_duration_minutes
    @recently_completed = Current.user.recently_completed.includes(:authors).with_attached_cover_image
    @show_homescreen_notification = should_show_homescreen_notification?
    fresh_when Current.user
  end

  private

  def should_show_homescreen_notification?
    # Only show if:
    # 1. User is authenticated
    # 2. Not in a native app
    # 3. Cookie hasn't been set indicating they've already seen it
    authenticated? &&
      !native_app? &&
      !cookies[:homescreen_notification_shown]
  end
end
