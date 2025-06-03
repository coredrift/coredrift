require "test_helper"
require "securerandom"

class DailyReportJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers
  include ActionMailer::TestHelper

  def setup
    assemble_graph
  end

  test "skips job if day is not active" do
    travel_to Time.zone.parse("2025-06-02 10:30") do # Monday
      @setup.update!(monday: false)

      job = Job.create!(
        job_type: "report",
        target_id: @setup.id,
        scheduled_for: Time.current,
        state: "pending"
      )

      assert_no_emails do
        DailyReportJob.perform_now(job.id)
      end

      assert_equal "completed", job.reload.state
    end
  end

  test "skips job if no dailies for today" do
    travel_to Time.zone.parse("2025-06-02 10:30") do # Monday
      @setup.update!(monday: true)

      job = Job.create!(
        job_type: "report",
        target_id: @setup.id,
        scheduled_for: Time.current,
        state: "pending"
      )

      perform_enqueued_jobs do
        DailyReportJob.perform_now(job.id)
      end

      assert_equal "completed", job.reload.state
    end
  end

  test "sends daily report to all team members with freeform template" do
    travel_to Time.zone.parse("2025-06-02 10:30") do # Monday
      @setup.update!(monday: true, template: "freeform")

      # Create a daily for user1 but not for user2
      Daily.create!(
        user: @user1,
        team: @team,
        daily_setup: @setup,
        date: Date.current,
        visible_at: @setup.visible_at,
        reminder_at: @setup.reminder_at,
        daily_report_time: @setup.daily_report_time,
        freeform: "Working on feature X"
      )

      job = Job.create!(
        job_type: "report",
        target_id: @setup.id,
        scheduled_for: Time.current,
        state: "pending"
      )

      # Should send email to both users (one with daily, one without)
      assert_emails @team.users.count do
        perform_enqueued_jobs do
          DailyReportJob.perform_now(job.id)
        end
      end

      assert_equal "completed", job.reload.state

      # Verify email content for both users
      emails = ActionMailer::Base.deliveries
      email = emails.first

      assert_includes email.body.to_s, "Working on feature X"
      assert_includes email.body.to_s, @user2.name # Should be in missing users
    end
  end

  test "sends daily report to all team members with structured template" do
    travel_to Time.zone.parse("2025-06-02 10:30") do # Monday
      @setup.update!(monday: true, template: "yesterday_today_blockers")

      # Create a daily for user1 but not for user2
      Daily.create!(
        user: @user1,
        team: @team,
        daily_setup: @setup,
        date: Date.current,
        visible_at: @setup.visible_at,
        reminder_at: @setup.reminder_at,
        daily_report_time: @setup.daily_report_time,
        yesterday: "Completed feature A",
        today: "Working on feature B",
        blockers: "Waiting for API docs"
      )

      job = Job.create!(
        job_type: "report",
        target_id: @setup.id,
        scheduled_for: Time.current,
        state: "pending"
      )

      # Should send email to both users (one with daily, one without)
      assert_emails @team.users.count do
        perform_enqueued_jobs do
          DailyReportJob.perform_now(job.id)
        end
      end

      assert_equal "completed", job.reload.state

      # Verify email content for both users
      emails = ActionMailer::Base.deliveries
      email = emails.first

      assert_includes email.body.to_s, "Completed feature A"
      assert_includes email.body.to_s, "Working on feature B"
      assert_includes email.body.to_s, "Waiting for API docs"
      assert_includes email.body.to_s, @user2.name # Should be in missing users
    end
  end

  private

  def assemble_graph
    # Superadmin User
    @superadmin = User.create!(
      id: SecureRandom.uuid,
      username: "superadmin_#{SecureRandom.hex(4)}",
      name: "Super Admin",
      email_address: "superadmin_#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("superadmin"),
      role: "superadmin",
      is_active: true
    )

    # Member users
    @user1 = User.create!(
      id: SecureRandom.uuid,
      username: "user1_#{SecureRandom.hex(4)}",
      name: "User One",
      email_address: "user1_#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("password"),
      role: "member",
      is_active: true
    )

    @user2 = User.create!(
      id: SecureRandom.uuid,
      username: "user2_#{SecureRandom.hex(4)}",
      name: "User Two",
      email_address: "user2_#{SecureRandom.hex(4)}@example.com",
      password_digest: BCrypt::Password.create("password"),
      role: "member",
      is_active: true
    )

    # Organization
    @organization = Organization.create!(
      id: SecureRandom.uuid,
      slug: "test-org-#{SecureRandom.hex(4)}",
      name: "Test Organization",
      owner_id: @superadmin.id
    )

    # Team
    @team = Team.create!(
      id: SecureRandom.uuid,
      slug: "test-team-#{SecureRandom.hex(4)}",
      name: "Test Team",
      description: "Team for testing",
      organization: @organization
    )

    # Add users to the team
    TeamMembership.create!(team: @team, user: @user1)
    TeamMembership.create!(team: @team, user: @user2)

    # Daily Setup
    @setup = DailySetup.create!(
      id: SecureRandom.uuid,
      team: @team,
      slug: "test-team-daily-setup-#{SecureRandom.hex(4)}",
      name: "Daily Ritual for Test Team",
      description: "Daily setup for testing",
      visible_at: "09:30",
      reminder_at: "08:00",
      daily_report_time: "10:30",
      weekly_report_day: "fri",
      weekly_report_time: "17:00",
      template: "freeform",
      allow_comments: true,
      active: true,
      monday: true,
      tuesday: true,
      wednesday: true,
      thursday: true,
      friday: true,
      saturday: false,
      sunday: false,
      settings: {}
    )
  end

  def teardown
    ActionMailer::Base.deliveries.clear
  end
end
