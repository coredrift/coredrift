class Organization < ApplicationRecord
  has_many :organization_owners
  has_many :owners, through: :organization_owners, source: :user
  has_many :users
end