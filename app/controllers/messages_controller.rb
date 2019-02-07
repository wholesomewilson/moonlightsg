class MessagesController < ApplicationController
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @conversation_id = @conversation.id
    if @message.save
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body, :user_id, :timezone_offset, :photo)
  end

end
