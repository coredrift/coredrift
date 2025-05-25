class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform(daily_setup_id)
    Rails.logger.info "[DailyReminderJob] Would send reminder for DailySetup ##{daily_setup_id} (placeholder)"
  end
end
