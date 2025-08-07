require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Helper method to find navigation elements using semantic roles
  def within_navigation(&block)
    within("[role='navigation']", &block)
  end

  # Helper method to click on author details by their name (more user-focused)
  def click_author_details(author_name)
    # Find summary elements containing the author name and click them
    find("summary", text: author_name).click
  end
end
