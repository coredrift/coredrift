class DailyReportJob < ApplicationJob
  queue_as :default

  def perform(job_id)
    job = Job.find_by(id: job_id)
    return unless job

    begin
      job.update!(state: "processing")
      daily_setup = DailySetup.find_by(id: job.target_id)

      unless daily_setup
        Rails.logger.warn "[daily-report-job] daily setup with ID ##{job.target_id} not found. Skipping job."
        job.update!(state: "completed", executed_at: Time.current)
        return
      end

      current_day_method_name = Time.current.strftime("%A").downcase.to_sym

      unless daily_setup.send(current_day_method_name)
        Rails.logger.info "[daily-report-job] Skipped for daily setup ##{daily_setup.id}. Day '#{current_day_method_name}' is not active."
        job.update!(state: "completed", executed_at: Time.current)
        return
      end

      team = daily_setup.team
      daily_report = DailyReport.find_or_create_by!(
        daily_setup: daily_setup,
        team: team,
        date: Date.current
      )

      dailies = team.dailies.where(
        date: Date.current,
        daily_setup_id: daily_setup.id
      ).to_a

      Daily.where(id: dailies.map(&:id)).update_all(daily_report_id: daily_report.id)

      team_users = team.users.to_a
      reported_teams = dailies.map(&:team).uniq
      missing_users = team_users.reject { |u| reported_teams.any? { |t| t.users.include?(u) } }

      team.users.find_each do |user|
        DailyReportMailer.daily_summary(user, team, daily_setup, dailies, missing_users).deliver_later
      end

      daily_report.publish!

      Rails.logger.info "[daily-report-job] Daily report sent and published for team ##{team.id}"
      job.update!(state: "completed", executed_at: Time.current)
    rescue => e
      job.update!(state: "failed", error_message: e.message)
      raise
    end
  end
end
