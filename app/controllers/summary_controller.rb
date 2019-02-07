class SummaryController < ApplicationController
  #before_action :authenticate_user!

  def show
    @lesson = Lesson.find_by_token(params[:id])
    if user_signed_in?
      @rsvp = current_user.rsvps.build
    else
      @rsvp = @lesson.rsvps.build
      @guest = @rsvp.guests.build
    end
    @all_rsvps = @lesson.rsvps
  end

end
