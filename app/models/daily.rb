class Daily < ApplicationRecord
  belongs_to :team
  belongs_to :daily_setup

  validate :setup_belongs_to_same_team

  private

  def setup_belongs_to_same_team
    unless daily_setup.team_id == team_id
      errors.add(:daily_setup, "debe pertenecer al mismo team que la daily")
    end
  end
end
