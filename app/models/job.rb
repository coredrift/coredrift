class Job < ApplicationRecord
  before_create -> { self.id ||= SecureRandom.uuid }

  STATES = %w[pending enqueued processing completed failed].freeze

  validates :state, presence: true, inclusion: { in: STATES }

  STATES.each do |s|
    define_method("state_#{s}?") { state == s }
    scope "with_state_#{s}", -> { where(state: s) }
  end
end
