class ConversationsController < ApplicationController

  def read_update
    @conversation = Conversation.find(params[:conversation_id])
    if @conversation.read_status != current_user.id
      @conversation.update_attribute(:read_status, 0)
      Delayed::Job.find(@conversation.message_notification_job_id).destroy
    end
    render :nothing => true
  end
end
