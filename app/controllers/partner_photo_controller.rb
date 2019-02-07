class PartnerPhotoController < ApplicationController
  before_action :set_lesson

  def update
    add_job_photo(lesson_params[:job_photo])
  end

  def destroy
    remove_job_photo(params[:image_id].to_i)
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def remove_job_photo(index)
    @remain_images = @lesson.job_photo
    @remain_images.delete_at(index)
    @lesson.job_photo = @remain_images
    @lesson.remove_job_photo! if @remain_images.empty?
    @lesson.save
  end

  def add_job_photo(new_images)
    @images = @lesson.job_photo
    @images += new_images
    @lesson.job_photo = @images
    @lesson.save
  end

  def lesson_params
    params.require(:lesson).permit({job_photo: []})
  end
end
