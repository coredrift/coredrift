class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  before_create -> { self.id ||= SecureRandom.uuid }
end
