# Skip asset building
ENV["RAILS_SKIP_ASSET_BUILD"] = "true"

# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!
