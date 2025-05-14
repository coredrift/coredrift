class Daily < ApplicationRecord
  belongs_to :team
  belongs_to :daily_setup

  validate :daily_setup_belongs_to_same_team

  private

  def daily_setup_belongs_to_same_team
    unless daily_setup.team_id == team_id
      errors.add(:daily_setup, "must belong to the same team as the daily")
    end
  end
end
