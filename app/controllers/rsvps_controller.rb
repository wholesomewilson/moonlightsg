class RsvpsController < ApplicationController
  before_action :authenticate_user!
  before_action :needs_confirmation

  def create
    @lesson = Lesson.find(params[:rsvp][:attended_lesson_id])
    @rsvp = current_user.rsvps.create(rsvp_params.merge(attendee_id: current_user.id)) #Create RSVP with user signed in
    redirect_to @lesson
  end

  def destroy
    @rsvp = Rsvp.find(params[:id])
    @lesson = Lesson.find(@rsvp[:attended_lesson_id])
	  current_user.rsvps.destroy(@rsvp)
	  redirect_to :back
  end

  private
  def rsvp_params
    params.require(:rsvp).permit(:attended_lesson_id, :endpoint, :p256dh, :auth, :bid)
  end
end
