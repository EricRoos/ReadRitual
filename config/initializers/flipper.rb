# Flipper Feature Flags Configuration
require "flipper"
require "flipper/adapters/active_record"

# Configure Flipper to use ActiveRecord for persistence
Flipper.configure do |config|
  config.adapter { Flipper::Adapters::ActiveRecord.new }
end

# Preload any default feature flags if needed
# Rails.application.config.after_initialize do
#   # Example: Enable a feature flag by default
#   # Flipper.enable(:new_dashboard)
# end
