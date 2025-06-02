require "test_helper"
require "uuidtools"
require "bcrypt"

class Rules
  def self.should_enqueue_reminder?(setup, current_time)
    scheduled_reminder_time = Time.zone.parse("#{current_time.to_date} #{setup.reminder_at}")
    scheduled_reminder_time <= current_time
  end

  def self.should_enqueue_report?(setup, current_time)
    scheduled_report_time = Time.zone.parse("#{current_time.to_date} #{setup.daily_report_time}")
    scheduled_report_time <= current_time
  end

  def self.should_enqueue_weekly_report?(setup, current_time)
    current_wday = Date::ABBR_DAYNAMES[current_time.wday].downcase
    if setup.weekly_report_day == current_wday
      scheduled_weekly_time = Time.zone.parse("#{current_time.to_date} #{setup.weekly_report_time}")
      return scheduled_weekly_time <= current_time
    end
    false
  end
end
