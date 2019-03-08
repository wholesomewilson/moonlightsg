class MessagesController < ApplicationController
  before_action :set_conversation

  def create
    @message = @conversation.messages.create(message_params)
    @conversation_id = @conversation.id
    @cuser = current_user.id
    if @message.save
      store_photos
      @message.reload
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

  def store_photos
    photo = params[:message][:photo]
    @message.create_chatimage(image: photo) if photo
  end

end
