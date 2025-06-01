class Organization < ApplicationRecord
  before_create -> { self.id ||= SecureRandom.uuid }
  has_many :organization_owners
  has_many :owners, through: :organization_owners, source: :user
  has_many :users
end