# Scheduler execution interval (default: 30s in development)
# This value should and will be configurable.
SCHEDULER_INTERVAL = ENV.fetch("SCHEDULER_INTERVAL", Rails.env.development? ? "30s" : "1m")

require "rufus-scheduler"

return unless defined?(Rails::Server)

scheduler = Rufus::Scheduler.new

scheduler.every SCHEDULER_INTERVAL do
  Rails.logger.info "[rufus-scheduler] Running DailyScheduler.check!"
  DailyScheduler.check!
end
