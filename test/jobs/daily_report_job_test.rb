require "test_helper"

class DailyReportJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    owner = User.create!(email_address: "ownerrep@example.com", username: "ownerrep", password: "password")
    @organization = Organization.create!(name: "Org Report", slug: "org-report-#{SecureRandom.hex(4)}", owner_id: owner.id)
    @team = Team.create!(name: "Report Team", organization: @organization, slug: "report-team-#{SecureRandom.hex(4)}")
    @daily_setup = DailySetup.create!(
      team: @team,
      name: "Report Test Setup",
      slug: "report-test-setup-" + SecureRandom.hex(4),
      monday: true,    # Active
      tuesday: false,  # Inactive
      wednesday: true,
      thursday: true,
      friday: true,
      saturday: false,
      sunday: false,
      daily_report_time: "10:00"
    )
    @log_output = StringIO.new
    @original_logger = Rails.logger
    test_logger = Logger.new(@log_output)
    test_logger.level = Logger::INFO
    test_logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    Rails.logger = test_logger
  end

  def teardown
    Rails.logger = @original_logger
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

  def flush_logger
    Rails.logger&.flush if Rails.logger.respond_to?(:flush)
    @log_output.flush if @log_output.respond_to?(:flush)
  end

  def log_messages
    flush_logger
    @log_output.rewind
    @log_output.read
  end

  # Helper to assert logs (reliable version)
  private

  def capture_rails_logs
    log_output = StringIO.new
    original_logger = Rails.logger
    Rails.logger = Logger.new(log_output)
    yield
    log_output.string
  ensure
    Rails.logger = original_logger
  end

  public

  test "publishes report when day is active (e.g., Monday)" do
    travel_to Time.zone.local(2025, 6, 2, 10, 5, 0) do # Monday, 10:05 AM
      log_output = StringIO.new
      logger = Logger.new(log_output)
      logger.level = Logger::INFO
      logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
      original_logger = Rails.logger
      Rails.logger = logger
      begin
        DailyReportJob.perform_now(@daily_setup.id)
        log_output.rewind
        logs = log_output.read
        assert_match(/\[DailyReportJob\] Would publish daily report for DailySetup ##{@daily_setup.id}/, logs)
      ensure
        Rails.logger = original_logger
      end
    end
  end

  test "does not publish report when day is inactive (e.g., Tuesday)" do
    travel_to Time.zone.local(2025, 6, 3, 10, 5, 0) do # Tuesday, 10:05 AM
      log_output = StringIO.new
      logger = Logger.new(log_output)
      logger.level = Logger::INFO
      logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
      original_logger = Rails.logger
      Rails.logger = logger
      begin
        DailyReportJob.perform_now(@daily_setup.id)
        log_output.rewind
        logs = log_output.read
        assert_match(/\[DailyReportJob\] Skipped for DailySetup ##{@daily_setup.id}. Day 'tuesday' is not active./, logs)
      ensure
        Rails.logger = original_logger
      end
    end
  end

  test "handles missing DailySetup gracefully" do
    non_existent_setup_id = SecureRandom.uuid
    log_output = StringIO.new
    logger = Logger.new(log_output)
    logger.level = Logger::WARN
    logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    original_logger = Rails.logger
    Rails.logger = logger
    begin
      assert_nothing_raised do
        DailyReportJob.perform_now(non_existent_setup_id)
      end
      log_output.rewind
      logs = log_output.read
      assert_match(/\[DailyReportJob\] DailySetup with ID ##{non_existent_setup_id} not found. Skipping job./, logs)
    ensure
      Rails.logger = original_logger
    end
  end

  test "performs daily report job" do
    daily_setup = daily_setups(:daily_setup_one)
    job = jobs(:daily_report_job_one)

    DailyReportJob.perform_now(job.id)

    assert_equal "completed", job.reload.state
  end

  test "skips when daily setup not found" do
    assert_nothing_raised do
      DailyReportJob.perform_now(SecureRandom.uuid)
    end
  end

  test "skips when day is not active" do
    daily_setup = daily_setups(:daily_setup_one)
    daily_setup.update!(sunday: false)

    travel_to Time.zone.parse("2025-06-01") # A Sunday

    job = jobs(:daily_report_job_one)
    DailyReportJob.perform_now(job.id)

    assert_equal "completed", job.reload.state
  end
end
