class UserPermission < ApplicationRecord
  belongs_to :user
  belongs_to :permission

  before_create -> { self.id ||= SecureRandom.uuid }
end
