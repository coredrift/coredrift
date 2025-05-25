class DailyScheduler
  def self.check!
    Rails.logger.info "[DailyScheduler] check! executed successfully."
    today = Date.current
    now = Time.current.strftime("%H:%M")
    now_time = Time.zone.parse(now)
    wday = Date::ABBR_DAYNAMES[today.wday].downcase

    DailySetup.where(active: true).find_each do |setup|
      # Daily reminder
      scheduled_reminder_time = Time.zone.parse("#{today} #{setup.reminder_at}")
      job = Job.find_or_create_by!(job_type: "reminder", target_id: setup.id, scheduled_for: scheduled_reminder_time) do |j|
        j.state = "pending"
      end
      if job.previous_changes.any?
        Rails.logger.info "[Job] Created reminder job ##{job.id} for DailySetup ##{setup.id} at #{scheduled_reminder_time}"
      end
      if job.state == "pending" && job.scheduled_for <= Time.current
        job.update!(state: "enqueued")
        Rails.logger.info "[Job] Enqueued reminder job ##{job.id} for DailySetup ##{setup.id}"
        DailyReminderJob.perform_later(job.id)
      end

      # Daily report
      scheduled_report_time = Time.zone.parse("#{today} #{setup.daily_report_time}")
      job = Job.find_or_create_by!(job_type: "report", target_id: setup.id, scheduled_for: scheduled_report_time) do |j|
        j.state = "pending"
      end
      if job.previous_changes.any?
        Rails.logger.info "[Job] Created report job ##{job.id} for DailySetup ##{setup.id} at #{scheduled_report_time}"
      end
      if job.state == "pending" && job.scheduled_for <= Time.current
        job.update!(state: "enqueued")
        Rails.logger.info "[Job] Enqueued report job ##{job.id} for DailySetup ##{setup.id}"
        DailyReportJob.perform_later(job.id)
      end

      # Weekly report
      if setup.weekly_report_day == wday
        scheduled_weekly_time = Time.zone.parse("#{today} #{setup.weekly_report_time}")
        job = Job.find_or_create_by!(job_type: "weekly_report", target_id: setup.id, scheduled_for: scheduled_weekly_time) do |j|
          j.state = "pending"
        end
        if job.previous_changes.any?
          Rails.logger.info "[Job] Created weekly_report job ##{job.id} for DailySetup ##{setup.id} at #{scheduled_weekly_time}"
        end
        if job.state == "pending" && job.scheduled_for <= Time.current
          job.update!(state: "enqueued")
          Rails.logger.info "[Job] Enqueued weekly_report job ##{job.id} for DailySetup ##{setup.id}"
          DailyWeeklyReportJob.perform_later(job.id)
        end
      end
    end
  end
end
