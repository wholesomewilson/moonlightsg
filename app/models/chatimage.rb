class Chatimage < ActiveRecord::Base
  belongs_to :message
  mount_uploader :image, ChatimageUploader
end
