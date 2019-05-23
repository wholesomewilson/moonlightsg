class Deliveryslot < ActiveRecord::Base
  belongs_to :timeslot
  belongs_to :order
end
