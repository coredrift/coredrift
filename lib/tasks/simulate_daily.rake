namespace :daily do
  desc "Create dailies for Team 1 members (no report)"
  task simulate: :environment do
    team = Team.find_by!(slug: "test-team-1")
    daily_setup = team.daily_setup

    current_day = Time.current.strftime("%A").downcase.to_sym
    daily_setup.update!(current_day => true) unless daily_setup.send(current_day)

    daily_report = DailyReport.find_or_create_by!(
      daily_setup: daily_setup,
      team: team,
      date: Date.current
    )

    team.users.each do |user|
      next if Daily.exists?(team: team, date: Date.current, daily_setup: daily_setup, daily_report_id: daily_report.id, user: user)

      Daily.create!(
        team: team,
        daily_setup: daily_setup,
        daily_report_id: daily_report.id,
        user: user,
        date: Date.current,
        visible_at: daily_setup.visible_at,
        reminder_at: daily_setup.reminder_at,
        daily_report_time: daily_setup.daily_report_time,
        yesterday: "Working on feature X",
        today: "Will continue with feature X and start Y",
        blockers: "Need access to API Z"
      )
      puts "✓ Daily created for team #{team.name}"
    end

    puts "\n📋 Dailies created for #{team.name}"
    puts "🌐 You can trigger the report later using 'rake daily:trigger_report'"
  end

  desc "Make the daily report viewable for Team 1 (no emails, just web view)"
  task post_report: :environment do
    team = Team.find_by!(slug: "test-team-1")
    daily_setup = team.daily_setup

    # Enable the current day if it's not enabled
    current_day = Time.current.strftime("%A").downcase.to_sym
    daily_setup.update!(current_day => true) unless daily_setup.send(current_day)

    report = DailyReport.find_by(daily_setup: daily_setup, team: team, date: Date.current)
    if report
      report.publish!
      puts "✓ Report published for #{team.name}"
    else
      puts "No report found for today."
    end

    puts "\n📋 Report for #{team.name} is now viewable"
    puts "🌐 View the report at: /daily_setups/#{daily_setup.id}/report"
  end

  desc "Send report emails and publish report for Team 1"
  task trigger_report: :environment do
    team = Team.find_by!(slug: "test-team-1")
    daily_setup = team.daily_setup

    job = Job.create!(
      job_type: "report",
      target_id: daily_setup.id,
      scheduled_for: Time.current,
      state: "pending"
    )

    puts "\n🚀 Executing report..."
    DailyReportJob.perform_now(job.id)
    puts "✓ Report sent and published!"
    puts "\n📧 Report was sent via email"
    puts "🌐 View the report at: /daily_setups/#{daily_setup.id}/report"
  end

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
end
