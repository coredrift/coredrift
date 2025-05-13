class Resource < ApplicationRecord
  self.inheritance_column = nil

  has_many :resource_permissions, dependent: :destroy
  has_many :permissions, through: :resource_permissions, after_add: :invalidate_cache, after_remove: :invalidate_cache

  before_create -> { self.id ||= SecureRandom.uuid }
  after_save :invalidate_cache_if_permissions_changed

  validates :kind, presence: true
  validates :value, presence: true, uniqueness: { scope: :kind, message: "combination of kind and value must be unique" }

  private

  def invalidate_cache_if_permissions_changed
    Rails.cache.delete("resource_permissions_#{value}") if saved_change_to_attribute?(:permissions)
  end

  def invalidate_cache(_record = nil)
    Rails.logger.debug "Callback triggered for resource: #{id}, value: #{value}"
    Rails.logger.debug "Invalidating cache for resource: #{value}"
    Rails.logger.debug "Permissions association changed for resource: #{id}, value: #{value}"
    Rails.cache.delete("resource_permissions_#{value}")
  end
end
