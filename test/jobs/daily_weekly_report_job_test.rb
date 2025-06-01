require "test_helper"

class DailyWeeklyReportJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    owner = User.create!(email_address: "ownerweekly@example.com", username: "ownerweekly", password: "password")
    @organization = Organization.create!(name: "Org Weekly", slug: "org-weekly-#{SecureRandom.hex(4)}", owner_id: owner.id)
    @team = Team.create!(name: "Weekly Report Team", organization: @organization, slug: "weekly-report-team-#{SecureRandom.hex(4)}")
    @daily_setup = DailySetup.create!(
      team: @team,
      name: "Weekly Report Test Setup",
      slug: "weekly-report-test-setup-" + SecureRandom.hex(4),
      monday: true,
      tuesday: true,
      wednesday: false,
      thursday: true,
      friday: true,
      saturday: false,
      sunday: false,
      weekly_report_day: "fri",
      weekly_report_time: "17:00"
    )
  end

  private

  def capture_logs(&block)
    original_logger = Rails.logger
    log_output = StringIO.new
    Rails.logger = Logger.new(log_output)
    block.call
    Rails.logger = original_logger
    log_output.string
  end

  public

  test "publishes weekly report on designated day if it is also an active weekday" do
    travel_to Time.zone.local(2025, 6, 6, 17, 5, 0) do
      logs = capture_logs do
        DailyWeeklyReportJob.perform_now(@daily_setup.id)
      end
      assert_match "[DailyWeeklyReportJob] Would publish weekly report for DailySetup ##{@daily_setup.id}", logs
    end
  end

  test "skips weekly report on designated day if that weekday is generally inactive" do
    @daily_setup.update!(weekly_report_day: "wed", wednesday: false, friday: true)
    travel_to Time.zone.local(2025, 6, 4, 17, 5, 0) do
      logs = capture_logs do
        DailyWeeklyReportJob.perform_now(@daily_setup.id)
      end
      assert_match "[DailyWeeklyReportJob] Skipped for DailySetup ##{@daily_setup.id}. Day 'wednesday' is not generally active.", logs
      assert_no_match "[DailyWeeklyReportJob] Would publish weekly report", logs
    end
  end

  test "skips weekly report if not the designated weekly report day" do
    travel_to Time.zone.local(2025, 6, 5, 17, 5, 0) do
      logs = capture_logs do
        DailyWeeklyReportJob.perform_now(@daily_setup.id)
      end
      assert_match "[DailyWeeklyReportJob] Skipped for DailySetup ##{@daily_setup.id}. Not the designated weekly report day (fri).", logs
      assert_no_match "[DailyWeeklyReportJob] Would publish weekly report", logs
    end
  end

  test "handles missing DailySetup gracefully" do
    non_existent_setup_id = SecureRandom.uuid
    logs = capture_logs do
      assert_nothing_raised do
        DailyWeeklyReportJob.perform_now(non_existent_setup_id)
      end
    end
    assert_match "[DailyWeeklyReportJob] DailySetup with ID ##{non_existent_setup_id} not found. Skipping job.", logs
  end

  teardown do
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
