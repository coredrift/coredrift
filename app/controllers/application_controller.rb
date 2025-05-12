class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authorize_user

  private

  def authorize_user
    # Get the current controller#action
    resource_key = "#{controller_name}##{action_name}"

    # Fetch required permissions from cache or database
    required_permissions = Rails.cache.fetch("permissions_for_#{resource_key}", expires_in: 12.hours) do
      Resource.find_by(kind: "controller_action", value: resource_key)&.permissions&.pluck(:name) || []
    end

    # Compare with user permissions stored in session
    user_permissions = session[:permissions] || []

    Rails.logger.debug "[DEBUG] Resource Key: #{resource_key}"
    Rails.logger.debug "[DEBUG] Required Permissions: #{required_permissions}"
    Rails.logger.debug "[DEBUG] User Permissions: #{user_permissions}"
    Rails.logger.debug "[DEBUG] Missing Permissions: #{required_permissions - user_permissions}"

    unless (required_permissions - user_permissions).empty?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
