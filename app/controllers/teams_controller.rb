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
      redirect_to team_path(@team), notice: "Team was successfully created."
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

  def members
    @team = Team.find(params[:id])
    @members = @team.users
    @available_users = User.where.not(id: @members.pluck(:id))
  end

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

  def member_roles
    @team = Team.find(params[:id])
    @user = User.find(params[:user_id])
    @user_roles = UserRole.where(user: @user, context_type: "Team", context_id: @team.id).includes(:role)
    @available_roles = Role.where.not(id: @user_roles.pluck(:role_id))
  end

  def assign_contextual_role
    @team = Team.find(params[:id])
    @user = User.find(params[:user_id])
    @role = Role.find(params[:role_id])
    UserRole.create!(user: @user, role: @role, context_type: "Team", context_id: @team.id)
    redirect_to member_roles_team_path(@team, @user)
  end

  def remove_contextual_role
    @team = Team.find(params[:id])
    @user = User.find(params[:user_id])
    @role = Role.find(params[:role_id])
    user_role = UserRole.find_by(user: @user, role: @role, context_type: "Team", context_id: @team.id)
    user_role&.destroy
    redirect_to member_roles_team_path(@team, @user)
  end

  private

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
