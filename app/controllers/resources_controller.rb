class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy,
                                      :permissions, :assign_permission, :revoke_permission]

  # GET /resources
  def index
    @resources = Resource.all
  end

  # GET /resources/:id
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  # POST /resources
  def create
    @resource = Resource.new(resource_params)
    if @resource.save
      redirect_to @resource, notice: "Resource was successfully created."
    else
      render :new
    end
  end

  # GET /resources/:id/edit
  def edit
  end

  # PATCH/PUT /resources/:id
  def update
    if @resource.update(resource_params)
      redirect_to @resource, notice: "Resource was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /resources/:id
  def destroy
    @resource.destroy
    redirect_to resources_path, notice: 'Resource was successfully deleted.'
  end

  # GET /resources/:id/permissions
  def permissions
    @available_permissions = Permission.where.not(id: @resource.resource_permissions.select(:permission_id))
  end

  # POST /resources/:id/assign_permission
  def assign_permission
    perm = Permission.find(params[:permission_id])
    @resource.resource_permissions.create(permission: perm) unless @resource.permissions.exists?(perm.id)
    Rails.logger.info "Permission #{perm.id} successfully assigned to Resource #{@resource.id}"
    redirect_to permissions_resource_path(@resource), notice: 'Permission assigned.'
  end

  # DELETE /resources/:id/permissions/:permission_id
  def revoke_permission
    perm = Permission.find(params[:permission_id])
    rp = @resource.resource_permissions.find_by(permission: perm)
    rp&.destroy
    redirect_to permissions_resource_path(@resource), notice: 'Permission revoked.'
  end

  private

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.require(:resource).permit(:name, :description)
  end
end