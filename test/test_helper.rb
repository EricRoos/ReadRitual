ENV["RAILS_ENV"] ||= "test"

# SimpleCov must be started before any application code is loaded
require "simplecov"
SimpleCov.start "rails" do
  # Set minimum coverage threshold - start conservative at 60%
  minimum_coverage 60
  
  # Configure command name for Minitest
  command_name "Minitest"
  
  # Add some additional filters
  add_filter "/vendor/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/script/"
  add_filter "/bin/"
  
  # Group coverage by functionality
  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Helpers", "app/helpers"
  add_group "Jobs", "app/jobs"
  add_group "Mailers", "app/mailers"
  add_group "Libraries", "lib"
  
  # Track branches for more comprehensive coverage
  enable_coverage :branch
end

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
  end
end
