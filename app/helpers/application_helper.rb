module ApplicationHelper
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
end
