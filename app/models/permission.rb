class Permission < ApplicationRecord
  before_create -> { self.id ||= SecureRandom.uuid }

  has_many :role_permissions,     dependent: :destroy
  has_many :roles, through: :role_permissions

  has_many :user_permissions,     dependent: :destroy
  has_many :users, through: :user_permissions

  has_many :resource_permissions, dependent: :destroy
  has_many :resources, through: :resource_permissions
end
