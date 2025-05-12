# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :destroy,
                                    :roles, :assign_role, :revoke_role,
                                    :permissions, :assign_permission, :revoke_permission ]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/:id
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "User was successfully created."
    else
      render :new
    end
  end

  # GET /users/:id/edit
  def edit
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    redirect_to users_path, notice: "User was successfully deleted."
  end

  # GET /users/:id/roles
  def roles
    @available_roles = Role.all
  end

  # POST /users/:id/assign_role
  def assign_role
    role = Role.find(params[:role_id])
    unless @user.roles.exists?(id: role.id)
      @user.user_roles.create(role: role)
    end
    redirect_to roles_user_path(@user), notice: "Role assigned."
  end

  # DELETE /users/:id/roles/:role_id
  def revoke_role
    role = Role.find(params[:role_id])
    @user.roles.destroy(role)
    redirect_to roles_user_path(@user), notice: "Role revoked."
  end

  # GET /users/:id/permissions
  def permissions
    @available_permissions = Permission.where.not(id: @user.user_permissions.select(:permission_id))
  end

  # POST /users/:id/assign_permission
  def assign_permission
    perm = Permission.find(params[:permission_id])
    unless @user.permissions.exists?(id: perm.id)
      if @user.user_permissions.create(permission: perm)
        Rails.logger.info "Permission #{perm.id} successfully assigned to User #{@user.id}"
      else
        Rails.logger.error "Failed to assign Permission #{perm.id} to User #{@user.id}: #{@user.user_permissions.errors.full_messages.join(', ')}"
      end
    end
    session[:permissions] = @user.all_permissions if @user.id == current_user&.id
    redirect_to permissions_user_path(@user), notice: "Permission assigned."
  end

  # DELETE /users/:id/permissions/:permission_id
  def revoke_permission
    perm = Permission.find(params[:permission_id])
    up = @user.user_permissions.find_by(permission: perm)
    up&.destroy
    session[:permissions] = @user.all_permissions if @user.id == current_user&.id
    redirect_to permissions_user_path(@user), notice: "Permission revoked."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email_address, :password, :password_confirmation)
  end
end
