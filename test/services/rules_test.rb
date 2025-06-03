require "test_helper"
require "uuidtools"
require "bcrypt"

class RulesTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def setup
    assemble_graph
  end

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
    @setup.update!(monday: false)
    current_time = Time.zone.parse("2023-10-02 08:00")
    assert_equal "monday", current_time.strftime("%A").downcase
    current_day_method_name = current_time.strftime("%A").downcase.to_sym
    refute @setup.send(current_day_method_name), "Monday should be inactive"
  end

  test "should respect active days for reminders" do
    @setup.update!(tuesday: true)
    current_time = Time.zone.parse("2023-10-03 08:00") # Tuesday
    assert_equal "tuesday", current_time.strftime("%A").downcase
    current_day_method_name = current_time.strftime("%A").downcase.to_sym
    assert @setup.send(current_day_method_name), "Tuesday should be active"
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
      description: "Default organization for initial setup.",
      short_description: "Default single-instance organization",
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