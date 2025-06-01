class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform(job_id)
    job = Job.find(job_id)
    job.update!(state: "processing")
    daily_setup = DailySetup.find(job.target_id)

    current_day_method_name = Time.current.strftime("%A").downcase.to_sym

    unless daily_setup.send(current_day_method_name)
      Rails.logger.info "[DailyReminderJob] Skipped for daily ##{daily_setup.id} (Job ##{job.id}). Day '#{current_day_method_name}' is not active."
      job.update!(state: "completed", executed_at: Time.current)
      return
    end

    team = daily_setup.team
    team.users.each do |user|
      DailyReminderMailer.reminder_email(user, daily_setup).deliver_later
    end
    job.update!(state: "completed", executed_at: Time.current)
  rescue => e
    job.update!(state: "failed", error_message: e.message)
    raise
  end
end
