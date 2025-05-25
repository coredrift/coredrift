class DailyScheduler
  def self.check!
    Rails.logger.info "[DailyScheduler] check! executed successfully."
    today = Date.current
    now = Time.current.strftime("%H:%M")
    now_time = Time.zone.parse(now)
    wday = Date::ABBR_DAYNAMES[today.wday].downcase

    DailySetup.where(active: true).find_each do |setup|
      # Daily reminder
      reminder_time = Time.zone.parse(setup.reminder_at)
      if setup.last_reminder_enqueued_at != today && reminder_time <= now_time
        DailyReminderJob.perform_later(setup.id)
        setup.update!(last_reminder_enqueued_at: today)
        Rails.logger.info "[DailyScheduler] Enqueued DailyReminderJob for #{setup.id}"
      end

      # Daily report
      report_time = Time.zone.parse(setup.daily_report_time)
      if setup.last_report_enqueued_at != today && report_time <= now_time
        DailyReportJob.perform_later(setup.id)
        setup.update!(last_report_enqueued_at: today)
        Rails.logger.info "[DailyScheduler] Enqueued DailyReportJob for #{setup.id}"
      end

      # Weekly report
      weekly_time = Time.zone.parse(setup.weekly_report_time)
      if setup.weekly_report_day == wday && setup.last_weekly_report_enqueued_at != today && weekly_time <= now_time
        DailyWeeklyReportJob.perform_later(setup.id)
        setup.update!(last_weekly_report_enqueued_at: today)
        Rails.logger.info "[DailyScheduler] Enqueued DailyWeeklyReportJob for #{setup.id}"
      end
    end
  end
end
