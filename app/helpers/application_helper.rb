module ApplicationHelper
  CELEBRATION_MESSAGES = [
    "Look at you, finishing books instead of doomscrolling. Proud of you.",
    "Congrats! That's one more book finished than most people start.",
    "Wow. You actually finished it. No half-read graveyard for this one.",
    "Congratulations! Now you can finally stop pretending you didn't peek at the last chapter."
  ].freeze

  def format_duration_minutes(minutes)
    return nil if minutes.nil?
    minutes = minutes.to_i # Ensure we work with an integer
    return nil if minutes.zero?

    hours = minutes / 60
    remaining_minutes = minutes % 60

    if hours > 0 && remaining_minutes > 0
      "#{pluralize(hours, 'hour')} #{pluralize(remaining_minutes, 'minute')}"
    elsif hours > 0
      pluralize(hours, "hour")
    else
      pluralize(remaining_minutes, "minute")
    end
  end

  def random_celebration_message
    CELEBRATION_MESSAGES.sample
  end

  def show_homescreen_notification?
    # Only show if:
    # 1. User is authenticated
    # 2. Not in a native app
    # 3. Cookie hasn't been set indicating they've already seen it
    authenticated? &&
      !native_app? &&
      !cookies[:homescreen_notification_shown]
  end
end
