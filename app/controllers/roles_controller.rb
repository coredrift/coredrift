class RolesController < ApplicationController
  before_action :set_role, only: [:show, :edit, :update, :destroy]

  # GET /roles
  def index
    @roles = Role.all
  end

  # GET /roles/:id
  def show
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # POST /roles
  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to @role, notice: "Role was successfully created."
    else
      render :new
    end
  end

  # GET /roles/:id/edit
  def edit
  end

  # PATCH/PUT /roles/:id
  def update
    if @role.update(role_params)
      redirect_to @role, notice: "Role was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /roles/:id
  def destroy
    @role.destroy
    redirect_to roles_path, notice: 'Role was successfully deleted.'
  end

  # GET /roles/:id/permissions
  def permissions
    @role = Role.find(params[:id])
    @available_permissions = Permission.where.not(id: @role.permissions.select(:id))
  end

  def assign_permission
    @role = Role.find(params[:id])
    permission = Permission.find(params[:permission_id])
    unless @role.permissions.exists?(id: permission.id)
      @role.role_permissions.create(permission: permission)
    end
    redirect_to permissions_role_path(@role), notice: 'Permission assigned.'
  end

  def revoke_permission
    @role = Role.find(params[:id])
    permission = Permission.find(params[:permission_id])
    role_permission = @role.role_permissions.find_by(permission: permission)
    role_permission&.destroy
    redirect_to permissions_role_path(@role), notice: 'Permission revoked.'
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:slug, :name, :description, :status, :created_by, :updated_by)
  end
end
