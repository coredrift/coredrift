class Team < ApplicationRecord
  before_create -> { self.id ||= SecureRandom.uuid }

  belongs_to :organization
  has_many :team_memberships, dependent: :destroy
  has_many :users, through: :team_memberships
  has_one :daily_setup, dependent: :destroy
  has_many :dailies, dependent: :destroy
  has_many :daily_reports, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :organization_id }
end
