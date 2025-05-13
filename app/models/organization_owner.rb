class OrganizationOwner < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  before_create :set_uuid

  private

  def set_uuid
    self.id ||= SecureRandom.uuid
  end
end
