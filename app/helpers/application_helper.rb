module ApplicationHelper
  def organization_uuid
    current_user&.organization&.uuid || "default"
  end
end
