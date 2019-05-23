class Timeslot < ActiveRecord::Base
  has_many :deliverslot, dependent: :destroy
end
