class Resource < ApplicationRecord
  self.inheritance_column = nil

  has_many :resource_permissions, dependent: :destroy
  has_many :permissions, through: :resource_permissions

  before_create -> { self.id ||= SecureRandom.uuid }

  validates :kind, presence: true, uniqueness: true
end
