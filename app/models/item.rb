class Item < ActiveRecord::Base
  mount_uploader :item_photo, ItemsUploader
  has_many :orderitems, dependent: :destroy
end
