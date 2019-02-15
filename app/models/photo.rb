class Photo < ActiveRecord::Base
  belongs_to :lesson
  mount_uploader :image, JobPhotoUploader
end
