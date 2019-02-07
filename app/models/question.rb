class Question < ActiveRecord::Base
  belongs_to :lesson
  has_one :answer
end
