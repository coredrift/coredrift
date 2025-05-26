class TeamMembership < ApplicationRecord
  before_create -> { self.id ||= SecureRandom.uuid }

  belongs_to :team
  belongs_to :user
end
