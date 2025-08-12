require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [ 1400, 1400 ]

  # Helper method to find navigation elements using semantic roles
  def within_navigation(&block)
    within("[role='navigation']", &block)
  end

  # Helper method to click on author details by their name (more user-focused)
  def click_author_details(author_name)
    # Use exact aria-label match to ensure we get the right author group
    # The aria-label format is "Toggle details for [author names]"
    find("summary[aria-label='Toggle details for #{author_name}']").click
  end
end
