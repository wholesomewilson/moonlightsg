class AddMessageNotificationJobIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :message_notification_job_id, :integer
  end
end
