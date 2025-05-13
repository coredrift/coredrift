class TeamsController < ApplicationController
  layout "core"

  def index
    @teams = Team.all
  end

  def show
    @team = Team.find(params[:id])
  end

  def edit
    @team = Team.find(params[:id])
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to team_path(@team), notice: 'Team was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @team = Team.find(params[:id])
    if @team.update(team_params)
      redirect_to team_path(@team), notice: "Team was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
