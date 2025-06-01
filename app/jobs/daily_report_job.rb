class DailyReportJob < ApplicationJob
  queue_as :default

  def perform(job_id)
    job = Job.find_by(id: job_id)
    return unless job

    begin
      job.update!(state: "processing")
      daily_setup = DailySetup.find_by(id: job.target_id)

      unless daily_setup
        Rails.logger.warn "[DailyReportJob] DailySetup with ID ##{job.target_id} not found. Skipping job."
        job.update!(state: "completed", executed_at: Time.current)
        return
      end

      current_day_method_name = Time.current.strftime("%A").downcase.to_sym

      unless daily_setup.send(current_day_method_name)
        Rails.logger.info "[DailyReportJob] Skipped for DailySetup ##{daily_setup.id}. Day '#{current_day_method_name}' is not active."
        job.update!(state: "completed", executed_at: Time.current)
        return
      end

      Rails.logger.info "[DailyReportJob] Would publish daily report for DailySetup ##{daily_setup.id}"
      job.update!(state: "completed", executed_at: Time.current)
    rescue => e
      job.update!(state: "failed", error_message: e.message)
      raise
    end
  end
end
