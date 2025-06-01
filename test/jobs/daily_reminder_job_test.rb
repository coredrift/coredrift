require "test_helper"

class DailyReminderJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers
  include ActionMailer::TestHelper

  setup do
    owner = User.create!(email_address: "ownerrem@example.com", username: "ownerrem", password: "password")
    @organization = Organization.create!(
      name: "Org Reminder",
      slug: "org-reminder-#{SecureRandom.hex(4)}",
      owner_id: owner.id
    )
    @team = Team.create!(name: "Reminder Team", organization: @organization, slug: "reminder-team-#{SecureRandom.hex(4)}")
    @user1 = User.create!(email_address: "user1@example.com", username: "user1rem", password: "password")
    @user2 = User.create!(email_address: "user2@example.com", username: "user2rem", password: "password")
    TeamMembership.create!(user: @user1, team: @team)
    TeamMembership.create!(user: @user2, team: @team)

    @daily_setup = DailySetup.create!(
      team: @team,
      name: "Reminder Test Setup",
      slug: "reminder-test-setup-" + SecureRandom.hex(4),
      monday: true,    # Active
      tuesday: false,  # Inactive
      wednesday: true,
      thursday: true,
      friday: true,
      saturday: false,
      sunday: false,
      reminder_at: "09:00"
    )
    @job_record = Job.create!(
      target_id: @daily_setup.id,
      state: "pending"
    )
  end

  test "sends reminders to all team members when day is active (e.g., Monday)" do
    travel_to Time.zone.local(2025, 6, 2, 9, 5, 0) do # Monday, 9:05 AM
      assert_emails @team.users.count do
        DailyReminderJob.perform_now(@job_record.id)
      end

      @job_record.reload
      assert_equal "completed", @job_record.state
    end
  end

  test "does not send reminders when day is inactive (e.g., Tuesday)" do
    travel_to Time.zone.local(2025, 6, 3, 9, 5, 0) do # Tuesday, 9:05 AM
      assert_no_emails do
        DailyReminderJob.perform_now(@job_record.id)
      end

      @job_record.reload
      assert_equal "completed", @job_record.state # Job completes but logs skip
    end
  end

  test "handles missing DailySetup and marks job as failed" do
    job_for_missing_setup = Job.create!(
      target_id: SecureRandom.uuid,
      state: "pending"
    )

    DailyReminderJob.perform_now(job_for_missing_setup.id)

    job_for_missing_setup.reload
    assert_equal "failed", job_for_missing_setup.state
    assert_match /Couldn't find DailySetup/, job_for_missing_setup.error_message
  end

  test "handles missing Job record gracefully (though job wouldn't start)" do
    non_existent_job_id = SecureRandom.uuid

    assert_raises ActiveRecord::RecordNotFound do
      DailyReminderJob.perform_now(non_existent_job_id)
    end
  end

  teardown do
    ActionMailer::Base.deliveries.clear
    begin; SolidQueue::ReadyExecution.delete_all; rescue; end
    begin; SolidQueue::BlockedExecution.delete_all; rescue; end
    begin; SolidQueue::ClaimedExecution.delete_all; rescue; end
    begin; SolidQueue::FailedExecution.delete_all; rescue; end
    begin; SolidQueue::RecurringExecution.delete_all; rescue; end
    begin; SolidQueue::ScheduledExecution.delete_all; rescue; end
    begin; SolidQueue::RecurringTask.delete_all; rescue; end
    begin; SolidQueue::Semaphore.delete_all; rescue; end
    begin; SolidQueue::Pause.delete_all; rescue; end
    begin; SolidQueue::Process.delete_all; rescue; end
    begin; SolidQueue::Job.delete_all; rescue; end
    begin; Session.delete_all; rescue; end
    begin; ResourcePermission.delete_all; rescue; end
    begin; UserPermission.delete_all; rescue; end
    begin; RolePermission.delete_all; rescue; end
    begin; UserRole.delete_all; rescue; end
    begin; TeamMembership.delete_all; rescue; end
    begin; Job.delete_all; rescue; end
    begin; Daily.delete_all; rescue; end
    begin; DailySetup.delete_all; rescue; end
    begin; OrganizationOwner.delete_all; rescue; end
    begin; Resource.delete_all; rescue; end
    begin; Permission.delete_all; rescue; end
    begin; Role.delete_all; rescue; end
    begin; User.delete_all; rescue; end
    begin; Team.delete_all; rescue; end
    begin; Organization.delete_all; rescue; end
  end
end
