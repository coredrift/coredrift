class DashController < ApplicationController
  def add_member
    @team = Team.find(params[:id])
    user = User.find(params[:user_id])
    unless @team.users.exists?(user.id)
      @team.team_memberships.create(id: SecureRandom.uuid, user: user)
      redirect_to members_team_path(@team), notice: "User #{user.username} added to the team."
    else
      redirect_to members_team_path(@team), alert: "User #{user.username} is already a member of the team."
    end
  end

  def remove_member
    @team = Team.find(params[:id])
    user = User.find(params[:user_id])
    membership = @team.team_memberships.find_by(user: user)
    if membership
      membership.destroy
      redirect_to members_team_path(@team), notice: "User #{user.username} removed from the team."
    else
      redirect_to members_team_path(@team), alert: "User #{user.username} is not a member of the team."
    end
  end

  def dash
    @teams = current_user.teams.includes(:daily_setup)
    render :dash
  end
end