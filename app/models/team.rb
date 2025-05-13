class Team < ApplicationRecord
  belongs_to :organization
  has_many :team_memberships
  has_many :users, through: :team_memberships
end