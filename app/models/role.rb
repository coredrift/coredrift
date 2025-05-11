class Role < ApplicationRecord
  before_create -> { self.id ||= SecureRandom.uuid }

  attribute :status, :string, default: "enabled"

  has_many :user_roles,       dependent: :destroy
  has_many :users, through: :user_roles

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
end
