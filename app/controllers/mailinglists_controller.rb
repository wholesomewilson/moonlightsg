class MailinglistsController < ApplicationController
  def index
    @email = Email.new
  end

  def create
    @email = Email.create(email_params)
    respond_to do |format|
      if @email.save
        format.html { redirect_to :back, notice: "Thank you so much for indicating your interests in Moonlight! We will keep you informed when the marketplace is launched! :)" }
      end
    end
  end

private
  def email_params
    params.require(:email).permit(:body)
  end
end
