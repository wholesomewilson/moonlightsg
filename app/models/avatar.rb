class Avatar < ActiveRecord::Base
  belongs_to :user
  mount_uploader :image, ProfilePicUploader
  validates_integrity_of  :image
  validates_processing_of :image
end
