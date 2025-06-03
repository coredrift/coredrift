class DailiesController < ApplicationController
  before_action :set_daily_setup, only: [ :new, :create ]
  before_action :set_team, only: [ :new, :create ]
  before_action :set_daily_report, only: [ :new, :create ]

  def new
    @daily_setup = DailySetup.find(params[:daily_setup_id])
    @team = @daily_setup.team

    @daily = Daily.find_by(team_id: @team.id, date: Date.current)
    if @daily
      redirect_to edit_daily_path(@daily)
    else
      @daily = Daily.new(
        team_id: @team.id,
        daily_setup_id: @daily_setup.id,
        daily_report_id: @daily_report.id,
        date: Date.current,
        visible_at: @daily_setup.visible_at,
        reminder_at: @daily_setup.reminder_at,
        daily_report_time: @daily_setup.daily_report_time
      )
    end
  end

  def create
    @daily = Daily.new(daily_params)
    @daily.team_id = @team.id
    @daily.daily_setup_id = @daily_setup.id
    @daily.daily_report_id = @daily_report.id
    @daily.date = Date.current
    @daily.visible_at = @daily_setup.visible_at
    @daily.reminder_at = @daily_setup.reminder_at
    @daily.daily_report_time = @daily_setup.daily_report_time
    if @daily.save
      redirect_to dash_path, notice: "Daily created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @daily = Daily.find(params[:id])
  end

  def edit
    @daily = Daily.find(params[:id])
    @daily_setup = @daily.daily_setup
    @team = @daily.team
  end

  def update
    @daily = Daily.find(params[:id])
    if @daily.update(daily_params)
      redirect_to dash_path, notice: "Daily updated successfully."
    else
      @daily_setup = @daily.daily_setup
      @team = @daily.team
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_daily_setup
    @daily_setup = DailySetup.find(params[:daily_setup_id])
  end

  def set_team
    @team = @daily_setup.team
  end

  def set_daily_report
    @daily_report = DailyReport.find_or_create_by!(
      daily_setup: @daily_setup,
      team: @team,
      date: Date.current
    ) do |report|
      report.status = 'active'
    end
  end

  def daily_params
    params.require(:daily).permit(:freeform, :yesterday, :today, :blockers)
  end
end
