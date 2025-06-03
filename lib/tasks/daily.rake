# lib/tasks/daily.rake
desc "Create empty daily reports for all active setups for today (like DailyScheduler at start of day)"
task create_empty_report: :environment do
  puts "[daily:create_empty_report] Creating daily reports for today..."
  current_time = Time.current
  DailySetup.where(active: true).find_each do |setup|
    next unless DailyScheduler.should_enqueue_for_day?(setup, current_time)
    begin
      DailyReport.find_or_create_by!(daily_setup: setup, team: setup.team, date: Date.current) do |report|
        report.status = "active"
        puts "[daily:create_empty_report] Created new daily report for setup ##{setup.id} for date #{Date.current}"
      end
    rescue => e
      puts "[daily:create_empty_report] Failed to create daily report for setup ##{setup.id}: #{e.message}"
      next
    end
  end
  puts "[daily:create_empty_report] Done."
end
