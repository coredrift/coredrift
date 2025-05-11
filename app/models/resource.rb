class Resource < ApplicationRecord
  has_many :resource_permissions, dependent: :destroy
  has_many :permissions, through: :resource_permissions

  before_create -> { self.id ||= SecureRandom.uuid }
end
