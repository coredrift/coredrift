class ResourcePermission < ApplicationRecord
  belongs_to :resource
  belongs_to :permission

  before_create -> { self.id ||= SecureRandom.uuid }
end
