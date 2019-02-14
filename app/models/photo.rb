class Photo < ActiveRecord::Base
  belongs_to :lesson
  mount_uploader :image, JobPhotoUploader
  validates_integrity_of  :image
  validates_processing_of :image
end
