class ProfilesController < ApplicationController
  before_action :set_user
  def show
    @lesson_completed_owner = Lesson.find(@user.completed_problems_owner).sort_by { |x| x.job_completed_datetime }.reverse!
    @lesson_completed_solver = Lesson.find(@user.completed_problems_solver).sort_by { |x| x.job_completed_datetime }.reverse!
    @review_owner = Review.where(user_id: @user.id).where("rating_owner IS NOT NULL").where("length(body) > ?", 0)
    @review_solver= Review.where(user_id: @user.id).where("rating_solver IS NOT NULL").where("length(body) > ?", 0)
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
end
