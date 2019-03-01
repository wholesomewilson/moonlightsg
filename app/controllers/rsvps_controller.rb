class RsvpsController < ApplicationController
  before_action :authenticate_user!
  #before_action :needs_confirmation
  before_action :fill_up_profile_details, only: [:create]

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

  def update
    @rsvp = Rsvp.find(params[:id])
    @lesson = Lesson.find(@rsvp[:attended_lesson_id])
    respond_to do |format|
      if @rsvp.update(rsvp_params)
        format.html { redirect_to @lesson, notice: 'Your bid is successfully cancelled.' }
        format.json { render :show, status: :ok, location: @lesson }
      else
        format.html { render :edit }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def rsvp_params
    params.require(:rsvp).permit(:attended_lesson_id, :endpoint, :p256dh, :auth, :bid, :bid_withdraw)
  end
end
