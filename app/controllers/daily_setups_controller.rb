class DailySetupsController < ApplicationController
  def new
    @team = Team.find(params[:team_id])
    @daily_setup = DailySetup.new(team_id: @team.id, name: "Daily Standup for #{@team.name}")
  end

  def create
    @team = Team.find(params[:team_id])
    @daily_setup = DailySetup.new(daily_setup_params)
    @daily_setup.team_id = @team.id
    if @daily_setup.save
      redirect_to dash_path, notice: "Daily setup created successfully."
    else
      flash.now[:alert] = @daily_setup.errors.full_messages.to_sentence.presence || "Could not Report setup."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @daily_setup = DailySetup.find(params[:id])
  end

  def update
    @daily_setup = DailySetup.find(params[:id])
    if @daily_setup.update(daily_setup_params)
      redirect_to dash_path, notice: "Daily setup updated successfully."
    else
      flash.now[:alert] = @daily_setup.errors.full_messages.to_sentence.presence || "Could not update daily setup."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def daily_setup_params
    params.require(:daily_setup).permit(
      :slug, :name, :description,
      :visible_at, :reminder_at, :daily_report_time,
      :weekly_report_day, :weekly_report_time,
      :template, :allow_comments, :active,
      :settings,
      :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday
    )
  end
end
