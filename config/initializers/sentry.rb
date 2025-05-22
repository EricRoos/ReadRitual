# frozen_string_literal: true

if Rails.env.production?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = [ :active_support_logger ]
    # Add data like request headers and IP for users,
    # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
    config.send_default_pii = true

    config.traces_sample_rate = 0.2
    # or control sampling dynamically
    config.traces_sampler = lambda do |sampling_context|
      # sampling_context[:transaction_context] contains the information about the transaction
      # sampling_context[:parent_sampled] contains the transaction's parent's sample decision
      true # return value can be a boolean or a float between 0.0 and 1.0
    end
  end
end
