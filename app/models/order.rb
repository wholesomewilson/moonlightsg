class Order < ActiveRecord::Base
  has_many :orderitems, dependent: :destroy
  belongs_to :user
  has_one :location, dependent: :destroy
  has_one :deliveryslot, dependent: :destroy
end
