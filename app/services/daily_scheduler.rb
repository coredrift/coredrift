class DailyScheduler
  def self.check!
    Rails.logger.info "[daily-scheduler] check! executed successfully."
    current_time = Time.current

    DailySetup.where(active: true).find_each do |setup|
      next unless should_enqueue_for_day?(setup, current_time)
      
      # Create daily report at the start of each day
      begin
        DailyReport.find_or_create_by!(daily_setup: setup, team: setup.team, date: Date.current) do |report|
          report.status = 'active'
          Rails.logger.info "[daily-scheduler] Created new daily report for setup ##{setup.id} for date #{Date.current}"
        end
      rescue => e
        Rails.logger.error "[daily-scheduler] Failed to create daily report for setup ##{setup.id}: #{e.message}"
        next
      end

      if Rules.should_enqueue_reminder?(setup, current_time)
        scheduled_reminder_time = Time.zone.parse("#{current_time.to_date} #{setup.reminder_at}")
        job = Job.find_or_create_by!(job_type: "reminder", target_id: setup.id, scheduled_for: scheduled_reminder_time) do |j|
          j.state = "pending"
        end

        if job.previous_changes.any?
          Rails.logger.info "[daily-scheduler] Created reminder job ##{job.id} for daily setup ##{setup.id} at #{scheduled_reminder_time}"
        end

        if job.state == "pending" && job.scheduled_for <= current_time
          job.update!(state: "enqueued")
          Rails.logger.info "[daily-scheduler] Enqueued reminder job ##{job.id} for daily setup ##{setup.id}"
          DailyReminderJob.perform_later(job.id)
        end
      end

      if Rules.should_enqueue_report?(setup, current_time)
        scheduled_report_time = Time.zone.parse("#{current_time.to_date} #{setup.daily_report_time}")
        job = Job.find_or_create_by!(job_type: "report", target_id: setup.id, scheduled_for: scheduled_report_time) do |j|
          j.state = "pending"
        end

        if job.previous_changes.any?
          Rails.logger.info "[daily-scheduler] Created report job ##{job.id} for daily setup ##{setup.id} at #{scheduled_report_time}"
        end

        if job.state == "pending" && job.scheduled_for <= current_time
          job.update!(state: "enqueued")
          Rails.logger.info "[daily-scheduler] Enqueued report job ##{job.id} for daily setup ##{setup.id}"
          DailyReportJob.perform_later(job.id)
        end
      end

      if Rules.should_enqueue_weekly_report?(setup, current_time)
        scheduled_weekly_time = Time.zone.parse("#{current_time.to_date} #{setup.weekly_report_time}")
        job = Job.find_or_create_by!(job_type: "weekly_report", target_id: setup.id, scheduled_for: scheduled_weekly_time) do |j|
          j.state = "pending"
        end

        if job.previous_changes.any?
          Rails.logger.info "[daily-scheduler] Created weekly report job ##{job.id} for daily setup ##{setup.id} at #{scheduled_weekly_time}"
        end

        if job.state == "pending" && job.scheduled_for <= current_time
          job.update!(state: "enqueued")
          Rails.logger.info "[daily-scheduler] Enqueued weekly_report job ##{job.id} for daily setup ##{setup.id}"
          DailyWeeklyReportJob.perform_later(job.id)
        end
      end
    end
  end
  
  def self.should_enqueue_for_day?(setup, current_time)
    current_day_method_name = current_time.strftime("%A").downcase.to_sym
    setup.send(current_day_method_name)
  end
end
