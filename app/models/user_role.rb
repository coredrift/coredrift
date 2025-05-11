class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  before_create -> { self.id ||= SecureRandom.uuid }
end
