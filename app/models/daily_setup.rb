class DailySetup < ApplicationRecord
  include Slugifiable
  self.primary_key = :id
  before_create -> { self.id ||= SecureRandom.uuid }
  belongs_to :team

  TEMPLATE_LABELS = {
    "freeform" => "Freeform",
    "yesterday_today_blockers" => "Yesterday, Today & Blockers"
  }.freeze

  validates :name, presence: true

  def human_template
    TEMPLATE_LABELS[template] || template.to_s.titleize
  end

  # TODO: Temporary hack for showing daily setup details in the dashboard.
  # This should be replaced by a proper widgeting system for consistent info display.
  def details
    desc = description.to_s.strip
    desc_part = desc.present? ? "<br>#{desc}<br>" : "<br>"
    <<~HTML.html_safe
      <strong>#{name}</strong>#{desc_part}
      <strong>Visible At:</strong> #{visible_at}<br>
      <strong>Reminder At:</strong> #{reminder_at}<br>
      <strong>Template:</strong> #{human_template}<br>
      <strong>Daily Report Time:</strong> #{daily_report_time}<br>
      <strong>Weekly Report:</strong> #{weekly_report_day} at #{weekly_report_time}<br>
      <strong>Allow Comments:</strong> #{allow_comments ? 'Yes' : 'No'}<br>
      <strong>Active:</strong> #{active ? 'Yes' : 'No'}
    HTML
  end
end
