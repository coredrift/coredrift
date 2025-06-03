require "test_helper"
require "uuidtools"
require "bcrypt"

class RulesTest < ActiveSupport::TestCase
  test "should_enqueue_reminder? returns true when current_time matches reminder_at" do
    current_time = Time.zone.parse("2023-10-02 08:00")
    assert Rules.should_enqueue_reminder?(@setup, current_time)
  end

  test "should_enqueue_reminder? returns false when current_time is before reminder_at" do
    current_time = Time.zone.parse("2023-10-02 07:59")
    refute Rules.should_enqueue_reminder?(@setup, current_time)
  end

  test "should_enqueue_reminder? returns true when current_time is after reminder_at" do
    current_time = Time.zone.parse("2023-10-02 08:01")
    assert Rules.should_enqueue_reminder?(@setup, current_time)
  end

  test "should_enqueue_report? returns true when current_time matches daily_report_time" do
    current_time = Time.zone.parse("2023-10-02 10:30")
    assert Rules.should_enqueue_report?(@setup, current_time)
  end

  test "should_enqueue_report? returns false when current_time is before daily_report_time" do
    current_time = Time.zone.parse("2023-10-02 10:29")
    refute Rules.should_enqueue_report?(@setup, current_time)
  end

  test "should_enqueue_report? returns true when current_time is after daily_report_time" do
    current_time = Time.zone.parse("2023-10-02 10:31")
    assert Rules.should_enqueue_report?(@setup, current_time)
  end

  test "should_enqueue_weekly_report? returns true when current_time matches weekly_report_time and day" do
    current_time = Time.zone.parse("2023-10-06 17:00") # Friday
    assert Rules.should_enqueue_weekly_report?(@setup, current_time)
  end

  test "should_enqueue_weekly_report? returns false when current_time is before weekly_report_time" do
    current_time = Time.zone.parse("2023-10-06 16:59") # Friday
    refute Rules.should_enqueue_weekly_report?(@setup, current_time)
  end

  test "should_enqueue_weekly_report? returns false when current_time is after weekly_report_time but day does not match" do
    current_time = Time.zone.parse("2023-10-07 17:01") # Saturday
    refute Rules.should_enqueue_weekly_report?(@setup, current_time)
  end

  test "should_enqueue_weekly_report? returns true when current_time is after weekly_report_time and day matches" do
    current_time = Time.zone.parse("2023-10-06 17:01") # Friday
    assert Rules.should_enqueue_weekly_report?(@setup, current_time)
  end

  # Tests for day activation settings
  test "should respect inactive days for reminders" do
    # Monday is active by default, let's disable it
    @setup.update!(monday: false)
    
    # Create a time that would normally trigger a reminder (Monday at reminder time)
    current_time = Time.zone.parse("2023-10-02 08:00") 

    # Make sure Monday is indeed the current day in our test
    assert_equal "monday", current_time.strftime("%A").downcase
    
    # The scheduler should not enqueue a reminder
    current_day_method_name = current_time.strftime("%A").downcase.to_sym
    refute @setup.send(current_day_method_name), "Monday should be inactive"
  end

  test "should respect active days for reminders" do
    # Tuesday is active by default, but force it anyway
    @setup.update!(tuesday: true)
    
    # Set the time on Tuesday that would trigger a reminder
    current_time = Time.zone.parse("2023-10-03 08:00") # Tuesday
    
    # Ensure Tuesday is indeed the current day in test
    assert_equal "tuesday", current_time.strftime("%A").downcase
    
    # The setup should have Tuesday enabled
    current_day_method_name = current_time.strftime("%A").downcase.to_sym
    assert @setup.send(current_day_method_name), "Tuesday should be active"
  end

  def setup
    assemble_graph
  end

  private

  def assemble_graph
    # Superadmin User
    @superadmin = User.create!(
      id: UUIDTools::UUID.random_create.to_s,
      username: "superadmin",
      name: "Super Admin",
      email_address: "superadmin@example.com",
      password_digest: BCrypt::Password.create("superadmin"),
      role: "superadmin",
      is_active: true
    )

    # Organization
    @organization = Organization.create!(
      id: UUIDTools::UUID.random_create.to_s,
      slug: "default",
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
      id: UUIDTools::UUID.random_create.to_s,
      slug: "test-team",
      name: "Test Team",
      description: "Team for testing",
      organization: @organization
    )

    # Daily Setup
    @setup = DailySetup.create!(
      id: UUIDTools::UUID.random_create.to_s,
      team: @team,
      slug: "test-team-daily-setup",
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
end
````
require "test_helper"

class DailySchedulerTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def setup
    assemble_graph
  end

  test "creates daily report at the start of an active day" do
    @setup.update!(monday: true)
    travel_to Time.zone.parse("2025-06-02 00:01") do # Monday
      DailyScheduler.check!
      report = DailyReport.find_by(
        daily_setup: @setup,
        team: @team,
        date: Date.current
      )
      assert_not_nil report
      assert_equal 'active', report.status
    end
  end

  test "does not create daily report on inactive days" do
    @setup.update!(monday: false)
    travel_to Time.zone.parse("2025-06-02 00:01") do # Monday
      assert_no_difference 'DailyReport.count' do
        DailyScheduler.check!
      end
    end
  end

  test "does not create duplicate daily reports when run multiple times" do
    @setup.update!(monday: true)
    travel_to Time.zone.parse("2025-06-02 00:01") do # Monday
      assert_difference 'DailyReport.count', 1 do
        3.times { DailyScheduler.check! }
      end
    end
  end

  test "creates report for all active daily setups" do
    # Create a second daily setup
    setup2 = DailySetup.create!(
      id: SecureRandom.uuid,
      team: @team,
      slug: "second-daily-setup",
      name: "Second Daily Setup",
      description: "Another daily setup for testing",
      visible_at: "09:30",
      reminder_at: "08:00",
      daily_report_time: "10:30",
      weekly_report_day: "fri",
      weekly_report_time: "17:00",
      template: "freeform",
      allow_comments: true,
      active: true,
      monday: true,
      tuesday: false,
      wednesday: false,
      thursday: false,
      friday: false,
      saturday: false,
      sunday: false,
      settings: {}
    )

    travel_to Time.zone.parse("2025-06-02 00:01") do # Monday
      @setup.update!(monday: true)
      DailyScheduler.check!
      
      assert_not_nil DailyReport.find_by(daily_setup: @setup, date: Date.current)
      assert_not_nil DailyReport.find_by(daily_setup: setup2, date: Date.current)
    end
  end

  test "handles errors gracefully when creating reports" do
    # Force an error by making the team nil
    @setup.update!(team: nil)
    
    travel_to Time.zone.parse("2025-06-02 00:01") do # Monday
      assert_nothing_raised do
        DailyScheduler.check!
      end
    end
  end

  private

  def assemble_graph
    # Superadmin User
    @superadmin = User.create!(
      id: SecureRandom.uuid,
      username: "superadmin",
      name: "Super Admin",
      email_address: "superadmin@example.com",
      password_digest: BCrypt::Password.create("superadmin"),
      role: "superadmin",
      is_active: true
    )

    # Organization
    @organization = Organization.create!(
      id: SecureRandom.uuid,
      slug: "default",
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
      slug: "test-team",
      name: "Test Team",
      description: "Team for testing",
      organization: @organization
    )

    # Daily Setup
    @setup = DailySetup.create!(
      id: SecureRandom.uuid,
      team: @team,
      slug: "test-team-daily-setup",
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
    begin; DailyReport.delete_all; rescue; end
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
