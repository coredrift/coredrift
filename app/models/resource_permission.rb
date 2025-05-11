class ResourcePermission < ApplicationRecord
  belongs_to :resource
  belongs_to :permission
end
