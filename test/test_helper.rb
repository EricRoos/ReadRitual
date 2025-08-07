ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

      # Add more helper methods to be used by all tests here...
      def login_as(user)
        session = user.sessions.create!
        Current.session = session
        request = ActionDispatch::Request.new(Rails.application.env_config)
        cookies = request.cookie_jar
        cookies.signed[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end

      # used to look at the doms async loaded content that is
      # not available on the first page load and is loaded later
      def eventually_assert_text(text)
        Timeout.timeout(5) do
          loop do
            break if page.has_text?(text)
            sleep 0.1
          end
        end
      rescue Timeout::Error
        flunk "Expected text '#{text}' not found within the timeout period."
      end

      def scroll_to_bottom
        page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
      end
  end
end
