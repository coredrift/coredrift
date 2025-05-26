class OrganizationsController < ApplicationController
  layout "organization"

  def index
    @owners = User.where(username: "superadmin")
  end

  def show
    @organization = Organization.first
    unless @organization
      redirect_to root_path, alert: "Organization not found."
      return
    end
    @owners = User.where(id: OrganizationOwner.where(organization_id: @organization.id).pluck(:user_id))
  end

  def edit
    @organization = Organization.first
  end

  def update
    @organization = Organization.first
    if @organization.update(organization_params)
      redirect_to organization_path(@organization), notice: "Organization updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :short_description, :description)
  end
end
