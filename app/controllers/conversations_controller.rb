class ConversationsController < ApplicationController

  def read_update
    if Conversation.find(params[:conversation_id]).read_status != current_user.id
      Conversation.find(params[:conversation_id]).update_attribute(:read_status, 0)
    end
    render :nothing => true
  end

  def message_push
    Conversation.find(params[:conversation_id]).message_notification(params[:message_id])
    render :nothing => true
  end
end
