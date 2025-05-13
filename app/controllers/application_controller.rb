class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authorize_user, unless: :superadmin_user?

  private

  def authorize_user
    return if current_user.nil? 

    resource_key = "#{controller_name}##{action_name}"

    # Fetch required permissions from cache or database
    required_permissions = Rails.cache.fetch("resource_permissions_#{resource_key}", expires_in: 12.hours) do
      Resource.find_by(kind: "controller_action", value: resource_key)&.permissions&.pluck(:name) || []
    end

    if session[:session_stamp] != current_user.session_stamp
      session[:permissions] = current_user.permissions.pluck(:name)
      session[:session_stamp] = current_user.session_stamp
    end

    user_permissions = session[:permissions] || []

    Rails.logger.debug "Resource Key: #{resource_key}"
    Rails.logger.debug "Required Permissions: #{required_permissions}"
    Rails.logger.debug "User Permissions: #{user_permissions}"
    Rails.logger.debug "Missing Permissions: #{required_permissions - user_permissions}"

    unless (required_permissions - user_permissions).empty?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end

  def superadmin_user?
    current_user&.superadmin?
  end
end
