class DailiesController < ApplicationController
  before_action :set_daily_setup, only: [ :new, :create ]
  before_action :set_team, only: [ :new, :create ]

  def new
    @daily_setup = DailySetup.find(params[:daily_setup_id])
    @team = @daily_setup.team
    # if Time.current.strftime("%H:%M") > @daily_setup.daily_report_time
    #   redirect_to dash_path, alert: "It's too late to submit or update your daily for today."
    #   return
    # end
    @daily = Daily.find_by(user_id: current_user.id, team_id: @team.id, date: Date.current)
    if @daily
      redirect_to edit_daily_path(@daily)
    else
      @daily = Daily.new(
        user_id: current_user.id,
        team_id: @team.id,
        daily_setup_id: @daily_setup.id,
        date: Date.current,
        visible_at: @daily_setup.visible_at,
        reminder_at: @daily_setup.reminder_at,
        daily_report_time: @daily_setup.daily_report_time
      )
    end
  end

  def create
    @daily = Daily.new(daily_params)
    @daily.user_id = current_user.id
    @daily.team_id = @team.id
    @daily.daily_setup_id = @daily_setup.id
    @daily.date = Date.current
    @daily.visible_at = @daily_setup.visible_at
    @daily.reminder_at = @daily_setup.reminder_at
    @daily.daily_report_time = @daily_setup.daily_report_time
    if @daily.save
      redirect_to dash_path, notice: "Daily creado correctamente."
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

  def daily_params
    params.require(:daily).permit(:freeform, :yesterday, :today, :blockers)
  end
end
