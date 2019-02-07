class Notification < ActiveRecord::Base
  belongs_to :lesson
  validates_presence_of :endpoint, :p256dh, :auth
end
