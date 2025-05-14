module Slugifiable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_uuid_and_slug, on: :create
    validates :slug, uniqueness: true, allow_blank: true
  end

  private

  def ensure_uuid_and_slug
    self.id ||= SecureRandom.uuid if respond_to?(:id) && self.id.blank?
    if self.slug.blank? && self.name.present? && self.id.present?
      uuid_segment = self.id.to_s.split('-').last
      self.slug = "#{self.name.parameterize}-#{uuid_segment}"
    end
  end
end
