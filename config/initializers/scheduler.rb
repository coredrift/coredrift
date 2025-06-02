# Scheduler execution interval (default: 30s in development)
# This value should and will be configurable.
CD_SCHEDULER_INTERVAL = ENV.fetch("CD_SCHEDULER_INTERVAL", Rails.env.development? ? "30s" : "1m")

return unless defined?(Rails::Server)
return if Rails.env.test?

require_relative '../../app/services/daily_scheduler' 

require "rufus-scheduler"

scheduler = Rufus::Scheduler.new

scheduler.every CD_SCHEDULER_INTERVAL do
  Rails.logger.info "[scheduler] running daily scheduler check"
  DailyScheduler.check!
end
