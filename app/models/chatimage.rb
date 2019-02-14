class Chatimage < ActiveRecord::Base
  belongs_to :message
  mount_uploader :image, ChatimageUploader
  validates_integrity_of  :image
  validates_processing_of :image
end
