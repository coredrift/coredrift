class DailyReportJob < ApplicationJob
  queue_as :default

  def perform(daily_setup_id)
    Rails.logger.info "[DailyReportJob] Would publish daily report for DailySetup ##{daily_setup_id} (placeholder)"
  end
end
