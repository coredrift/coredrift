class DailyReportsController < ApplicationController
  before_action :set_team

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @team = current_user.teams.first
    @daily_reports = DailyReport.includes(:team, :daily_setup)
                               .where(team: current_user.teams, date: @date)
                               .where.not(published_at: nil)
  end

  def show
    @team = Team.find(params[:team_id])
    @daily_report = @team.daily_reports.find(params[:id])
    if !@daily_report.published?
      redirect_to dash_path, alert: "This report is not published yet."
      return
    end
    @date = @daily_report.date
    @daily_setup = @daily_report.daily_setup
    @dailies = @team.dailies.where(date: @date, daily_setup: @daily_setup)
    @missing_users = @team.users.where.not(id: @dailies.map(&:user_id))
  end

  private

  def set_team
    @team = current_user.teams.find(params[:team_id])
  end
end