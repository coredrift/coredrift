class DailyWeeklyReportJob < ApplicationJob
  queue_as :default

  def perform(daily_setup_id)
    daily_setup = DailySetup.find_by(id: daily_setup_id)

    unless daily_setup
      Rails.logger.warn "[daily-weekly-report-job] daily setup with ID ##{daily_setup_id} not found. Skipping job."
      return
    end

    current_day_name_sym = Time.current.strftime("%A").downcase.to_sym
    weekly_report_day_sym = daily_setup.weekly_report_day.downcase.to_sym

    is_weekly_report_day = (current_day_name_sym == weekly_report_day_sym)

    if is_weekly_report_day
      Rails.logger.info "[daily-weekly-report-job] Would publish weekly report for daily setup ##{daily_setup.id}"
    else
      Rails.logger.info "[daily-weekly-report-job] Skipped for daily setup ##{daily_setup.id}. Not the designated weekly report day (#{weekly_report_day_sym})."
    end
  end
end
