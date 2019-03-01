class DisputesController < ApplicationController

  def create
    @lesson = Lesson.find(params[:dispute][:lesson_id])
    @dispute = @lesson.disputes.create(dispute_params.merge(user_id: current_user.id))
    redirect_to :back
  end

  private
  def dispute_params
    params.require(:dispute).permit(:lesson_id, :body)
  end
end
