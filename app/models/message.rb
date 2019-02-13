class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  after_create :adjust_to_timezone
  after_create :update_convo_read
  mount_uploader :photo, ChatimageUploader
  has_one :chatimage, dependent: :destroy

  def adjust_to_timezone
    @sent_at_timezone = created_at + Conversation.find(conversation_id).timezone_offset.hour
    self.update_attribute(:sent_at_timezone, @sent_at_timezone)
  end

  def update_convo_read
    Conversation.find(conversation_id).update_attribute(:read_status, user_id)
  end
end
