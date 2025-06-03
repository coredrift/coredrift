require "test_helper"

class DailyReminderJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers
  include ActionMailer::TestHelper

  def setup
    assemble_graph
  end

  test "sends reminders to all team members when the day is active" do
    # Activate Monday (current day for the test)
    @setup.update!(monday: true)
    
    # Create a job for the daily setup
    @job = Job.create!(
      id: SecureRandom.uuid,
      job_type: "reminder",
      target_id: @setup.id,
      state: "pending",
      scheduled_for: Time.current
    )
    
    travel_to Time.zone.parse("2025-06-02 09:00") do # Monday, 9:00 AM
      assert_emails @team.users.count do
        DailyReminderJob.perform_now(@job.id)
      end

      @job.reload
      assert_equal "completed", @job.state
      assert_not_nil @job.executed_at
    end
  end

  test "does not send reminders when the day is inactive" do
    # Ensure Monday is inactive
    @setup.update!(monday: false)
    
    @job = Job.create!(
      id: SecureRandom.uuid,
      job_type: "reminder",
      target_id: @setup.id,
      state: "pending",
      scheduled_for: Time.current
    )
    
    travel_to Time.zone.parse("2025-06-02 09:00") do # Monday, 9:00 AM
      assert_no_emails do
        DailyReminderJob.perform_now(@job.id)
      end

      @job.reload
      assert_equal "completed", @job.state # Job is marked as completed even if no emails are sent
    end
  end

  test "handles errors when DailySetup does not exist" do
    job_with_nonexistent_setup = Job.create!(
      id: SecureRandom.uuid,
      job_type: "reminder",
      target_id: SecureRandom.uuid, # Non-existent ID
      state: "pending",
      scheduled_for: Time.current
    )

    assert_raises ActiveRecord::RecordNotFound do
      DailyReminderJob.perform_now(job_with_nonexistent_setup.id)
    end

    job_with_nonexistent_setup.reload
    assert_equal "failed", job_with_nonexistent_setup.state
    assert_match /Couldn't find DailySetup/, job_with_nonexistent_setup.error_message
  end

  test "updates job state to failed when an error occurs" do
    # Activate Monday to ensure the job would normally run
    @setup.update!(monday: true)
    
    @job = Job.create!(
      id: SecureRandom.uuid,
      job_type: "reminder",
      target_id: @setup.id,
      state: "pending",
      scheduled_for: Time.current
    )
    
    error_message = "Test error"

    mock_mailer = Object.new
    def mock_mailer.deliver_later
      raise StandardError.new("Test error")
    end
    
    DailyReminderMailer.singleton_class.define_method(:reminder_email) do |*args|
      mock_mailer
    end
    
    travel_to Time.zone.parse("2025-06-02 09:00") do
      assert_raises StandardError do
        DailyReminderJob.perform_now(@job.id)
      end
    end
    
    @job.reload
    assert_equal "failed", @job.state
    assert_equal error_message, @job.error_message
    
    DailyReminderMailer.singleton_class.remove_method(:reminder_email)
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
      slug: "default-#{SecureRandom.hex(4)}",
      name: "Default Organization",
      short_description: "Default single-instance organization",
      description: "Default organization for initial setup.",
      owner_id: @superadmin.id 
    )

    OrganizationOwner.create!(
      organization_id: @organization.id,
      user_id: @superadmin.id
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
      monday: false,
      tuesday: false, 
      wednesday: false, 
      thursday: false,
      friday: false, 
      saturday: false, 
      sunday: false,
      settings: {}
    )
  end

  def teardown
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
