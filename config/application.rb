require_relative "boot"
require_relative "../lib/bootstrapper"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CoreDrift
    class Application < Rails::Application
        # Initialize configuration defaults for originally generated Rails version.
        config.load_defaults 8.0

        # Please, add to the `ignore` list any other `lib` subdirectories that do
        # not contain `.rb` files, or that should not be reloaded or eager loaded.
        # Common ones are `templates`, `generators`, or `middleware`, for example.
        config.autoload_lib(ignore: %w[assets tasks])

        # Ensure UUID is recognized as the default primary key type for all entities
        config.generators do |g|
            g.orm :active_record, primary_key_type: :uuid
        end

        config.active_record.schema_format = :sql

        config.logger = ActiveSupport::Logger.new(STDOUT)
        config.logger.formatter = proc do |severity, datetime, progname, msg|
            level = {
                "DEBUG" => "[DBG]",
                "INFO" => "[INF]",
                "WARN" => "[WRN]",
                "ERROR" => "[ERR]",
                "FATAL" => "[FTL]",
                "UNKNOWN" => "[UNK]"
            }[severity] || "[UNK]"
            "#{level} #{datetime}: #{msg}\n"
        end

      # Configuration for the application, engines, and railties goes here.
      #
      # These settings can be overridden in specific environments using the files
      # in config/environments, which are processed later.
      #
      # config.time_zone = "Central Time (US & Canada)"
      # config.eager_load_paths << Rails.root.join("extras")
    end
end
