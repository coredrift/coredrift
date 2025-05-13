class PermissionsController < ApplicationController
  layout "auth"
  before_action :set_permission, only: [:show, :edit, :update, :destroy]

  # GET /permissions
  def index
    @permissions = Permission.all
  end

  # GET /permissions/:id
  def show
  end

  # GET /permissions/new
  def new
    @permission = Permission.new
  end

  # POST /permissions
  def create
    @permission = Permission.new(permission_params)
    if @permission.save
      redirect_to @permission, notice: "Permission was successfully created."
    else
      render :new
    end
  end

  # GET /permissions/:id/edit
  def edit
  end

  # PATCH/PUT /permissions/:id
  def update
    if @permission.update(permission_params)
      redirect_to @permission, notice: "Permission was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /permissions/:id
  def destroy
    @permission.destroy
    redirect_to permissions_path, notice: 'Permission was successfully deleted.'
  end

  private

  def set_permission
    @permission = Permission.find(params[:id])
  end

  def permission_params
    params.require(:permission).permit(:name, :description)
  end
end
