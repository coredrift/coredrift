class DailyReport < ApplicationRecord
  before_create -> { self.id ||= SecureRandom.uuid }

  belongs_to :daily_setup
  belongs_to :team
  has_many :dailies

  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active published] }
  validates :date, uniqueness: { scope: :daily_setup_id }

  def publish!
    update!(status: 'published', published_at: Time.current)
  end

  def published?
    published_at.present? && status == 'published'
  end
end