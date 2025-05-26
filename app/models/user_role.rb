class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :context, polymorphic: true, optional: true

  before_create -> { self.id ||= SecureRandom.uuid }
end
