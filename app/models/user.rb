class User < ApplicationRecord
  self.primary_key = :id
  before_create -> { self.id ||= SecureRandom.uuid }

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  has_many :user_roles,       dependent: :destroy
  has_many :roles, through: :user_roles, after_add: :increment_session_stamp, after_remove: :increment_session_stamp

  has_many :user_permissions, dependent: :destroy
  has_many :permissions, through: :user_permissions, after_add: :increment_session_stamp, after_remove: :increment_session_stamp

  after_save :update_session_stamp_if_permissions_changed

  def effective_permissions
    Permission
      .where(id: permissions.select(:id)) # Direct permissions
      .or(
        Permission.where(id: Permission.joins(:role_permissions).where(role_permissions: { role_id: roles.select(:id) }).select(:id)) # Role-based permissions
      ).distinct
  end

  # Returns all permissions (direct and role-based) as an array of permission names
  def all_permissions
    effective_permissions.pluck(:name)
  end

  # Groups permissions into unassigned, direct, and role-based categories
  def grouped_permissions
    assigned_permissions = permissions.pluck(:id)
    role_permissions = Permission.joins(:role_permissions).where(role_permissions: { role_id: roles.select(:id) }).distinct
    role_permission_ids = role_permissions.pluck(:id)
    direct_permission_ids = permissions.pluck(:id)

    {
      unassigned: Permission.where.not(id: direct_permission_ids + role_permission_ids).map { |perm| perm.attributes.merge(source: "unassigned") },
      direct: permissions.map { |perm| perm.attributes.merge(source: "direct") },
      role_based: role_permissions.where.not(id: direct_permission_ids).map do |perm|
        role_names = roles.joins(:role_permissions).where(role_permissions: { permission_id: perm.id }).pluck(:name)
        perm.attributes.merge(source: role_names.any? ? "From Role: #{role_names.join(', ')}" : "From Role: Unknown")
      end
    }
  end

  private

  def update_session_stamp_if_permissions_changed
    if saved_change_to_attribute?(:permissions)
      increment!(:session_stamp)
    end
  end

  def increment_session_stamp(_record = nil)
    Rails.logger.debug "Incrementing session_stamp for user: #{id}"
    increment!(:session_stamp)
  end
end
