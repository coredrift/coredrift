require "test_helper"
require "action_mailer/test_helper"

class DailyReminderJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers
  include ActionMailer::TestHelper

  test "skips job if day is not active" do
    travel_to Time.zone.parse("2025-06-02 09:00") do # lunes
      job, _ = build_reminder_job_for(day: :monday, active: false)

      perform_enqueued_jobs do
        DailyReminderJob.perform_later(job.id)
      end

      assert_equal "completed", job.reload.state
    end
  end

  test "sends mail to each user if day is active" do
    travel_to Time.zone.parse("2025-06-02 09:00") do # lunes
      job, _ = build_reminder_job_for(day: :monday, active: true)

      assert_emails 1 do
        perform_enqueued_jobs do
          DailyReminderJob.perform_later(job.id)
        end
      end

      assert_equal "completed", job.reload.state
    end
  end

  private

  def build_reminder_job_for(day:, active: true)
    suffix = SecureRandom.hex(4)
    user = User.create!(
      name: "User #{suffix}",
      email_address: "user_#{suffix}@localhost",
      password: "secret",
      is_active: true,
      role: "member"
    )

    admin = User.create!(
      name: "Admin #{suffix}",
      email_address: "admin_#{suffix}@localhost",
      password: "adminpass",
      is_active: true,
      role: "admin"
    )

    org = Organization.create!(
      name: "Org #{suffix}",
      slug: "org-#{suffix}",
      short_description: "desc",
      owner_id: admin.id
    )

    team = Team.create!(
      name: "Team #{suffix}",
      slug: "team-#{suffix}",
      organization: org
    )

    team.users << user

    setup = DailySetup.create!(
      name: "Daily Setup #{suffix}",
      slug: "daily-setup-#{suffix}",
      reminder_at: "09:00",
      daily_report_time: "10:00",
      active: true,
      monday: false, tuesday: false, wednesday: false, thursday: false,
      friday: false, saturday: false, sunday: false,
      team: team
    )

    setup.update!(day => active)

    job = Job.create!(
      job_type: "reminder",
      target_id: setup.id,
      scheduled_for: Time.current,
      state: "pending"
    )

    [job, user]
  end
end
