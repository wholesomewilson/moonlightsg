class Location < ActiveRecord::Base
  belongs_to :lesson
  default_scope { order('created_at ASC') } 
end
