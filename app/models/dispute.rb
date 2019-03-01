class Dispute < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :user
  after_create :update_raise_a_dispute

  def update_raise_a_dispute
    self.lesson.update_attribute(:raise_a_dispute, DateTime.current)
  end
end
