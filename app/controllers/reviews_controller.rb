class ReviewsController < ApplicationController
  def create
    @reviewee = User.find(params[:review][:user_id])
    @review = @reviewee.reviews.create(review_params.merge(reviewer_id: current_user.id))
    @lesson = Lesson.find(params[:review][:lesson_id])
    respond_to do |format|
      if @review.save
        if @lesson.organizer_id == current_user.id
          format.html { redirect_to lesson_owner_path }
        else
          format.html { redirect_to lesson_solver_path }
        end
      end
    end
  end

  private
  def review_params
    params.require(:review).permit(:body, :lesson_id, :user_id, :rating_solver, :rating_owner)
  end
end
