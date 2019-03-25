class Location < ActiveRecord::Base
  belongs_to :lesson
  default_scope { order('created_at ASC') }


  #before_update :push_to_changes_to_job_notification
  after_destroy :push_to_changes_to_job_notification
  before_save :push_to_changes_to_job_notification, :if => :check_old_job

  def check_old_job
    @created_time = self.lesson.created_at
    @time_difference = (DateTime.current.to_i - @created_time.to_i) / 60
    if @time_difference >= 1
      return true
    else
      return false
    end
  end

  def push_to_changes_to_job_notification
    if self.lesson.present?
      self.lesson.changes_to_job_notification
    end
  end
end
