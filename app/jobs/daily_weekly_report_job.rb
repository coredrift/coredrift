class DailyWeeklyReportJob < ApplicationJob
  queue_as :default

  def perform(daily_setup_id)
    Rails.logger.info "[DailyWeeklyReportJob] Would publish weekly report for DailySetup ##{daily_setup_id} (placeholder)"
  end
end
