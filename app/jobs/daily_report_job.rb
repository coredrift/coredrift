class DailyReportJob < ApplicationJob
  queue_as :default

  def perform(daily_setup_id)
    daily_setup = DailySetup.find_by(id: daily_setup_id) # Changed from find to find_by

    unless daily_setup # Added check for nil
      Rails.logger.warn "[DailyReportJob] DailySetup with ID ##{daily_setup_id} not found. Skipping job."
      return
    end

    current_day_method_name = Time.current.strftime("%A").downcase.to_sym # :monday, :tuesday, etc.

    unless daily_setup.send(current_day_method_name)
      Rails.logger.info "[DailyReportJob] Skipped for DailySetup ##{daily_setup.id}. Day '#{current_day_method_name}' is not active."
      return
    end

    Rails.logger.info "[DailyReportJob] Would publish daily report for DailySetup ##{daily_setup_id} (placeholder)"
  end
end
