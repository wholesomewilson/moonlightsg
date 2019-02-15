class Avatar < ActiveRecord::Base
  belongs_to :user
  mount_uploader :image, ProfilePicUploader
end
