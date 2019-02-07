class AddEmailJobIdAndPushJobIdToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :email_job_id, :integer
    add_column :rsvps, :push_job_id, :integer
  end
end
