class Orderitem < ActiveRecord::Base
  belongs_to :item
  belongs_to :order
  belongs_to :user
end
