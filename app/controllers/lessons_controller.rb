class LessonsController < ApplicationController
  include LessonsHelper
  before_action :set_lesson, only: [:show, :edit, :destroy]
  #before_action :check_signed_in, only: [:index]
  before_action :needs_confirmation, only: [:new]
  before_action :ensure_canonical_url, only: [:show]
  before_action :authenticate_user!, only: [:show]

  # GET /lessons
  # GET /lessons.json
  def search
    if params[:search].present?
      @lessons = Lesson.search(params[:search])
      if @lessons.blank?
        render :template => "lessons/_search_no_results"
      else
        respond_to do |format|
          format.html { render "index" }
        end
      end
    else
      @lessons = Lesson.where("datetime_awarded > ?", DateTime.current).where(awardee_id: nil)
    end
  end

  def index
    @lessons = Lesson.where("datetime_awarded > ?", DateTime.current).where(awardee_id: nil)
  end

  # GET /lessons/1
  # GET /lessons/1.json
  def show
    @rsvps = @lesson.rsvps.collect{ |rsvp| rsvp }.sort_by { |x| x.bid.to_i }
    @rsvp = Rsvp.new
    @bidders = @lesson.rsvps.collect{ |rsvp| rsvp.attendee_id}
    @question = Question.new
    @answer = @question.build_answer
    @questions = @lesson.questions
  end

  # GET /lessons/new
  def new
    @lesson = current_user.lessons.build
    @location = @lesson.locations.build
  end

  # GET /lessons/1/edit
  def edit

  end

  # POST /lessons
  # POST /lessons.json
  def create
    @lesson = current_user.lessons.build(lesson_params)
    respond_to do |format|
      if @lesson.save
        format.html { redirect_to @lesson, notice: 'Your Hoote was successfully created!<br>Share the Hoote with your friends via the url!' }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lessons/1
  # PATCH/PUT /lessons/1.json
  def update
    @lesson = Lesson.find(params[:id])
    @lesson.assign_attributes(lesson_params)
    @owner = User.find(@lesson.organizer_id)
    if @lesson.awardee_id.present?
      @solver = Rsvp.find(@lesson.awardee_id).attendee
    end
    @changed_attribute = @lesson.changed
    respond_to do |format|
      if @lesson.save
        if @changed_attribute == ["awardee_id"]
          @lesson.update_bounty_received_datetime
          format.html { redirect_to(lesson_owner_path) }
        elsif @changed_attribute == ["job_verified_datetime"]
          format.js { render 'review_owner.js.erb' }
        elsif @changed_attribute == ["job_completed_datetime"]
          format.js { render 'review_solver.js.erb' }
        else
          format.html { redirect_to(@lesson) }
        end
      end
    end
  end

  # DELETE /lessons/1
  # DELETE /lessons/1.json
  def destroy
    @lesson.destroy
    respond_to do |format|
      format.html { redirect_to lessons_url, notice: 'Your Hoote was successfully cancelled!<br>Create another Hoote!' }
      format.json { head :no_content }
    end
  end

  def add_location
    @lesson = current_user.lessons.build
    @location = @lesson.locations.build
    respond_to do |format|
      format.js {}
    end
  end

  def add_location_edit
    @lesson = current_user.lessons.build
    @location = @lesson.locations.build
    respond_to do |format|
      format.js {}
    end
  end

  def remove_image
    @lesson_id = params[:lesson_id].to_i
    @image_id = params[:image_id].to_i
    @lesson = Lesson.find(@lesson_id)
    @new_job_photos = @lesson.job_photo
    if params[:image_id] == 0 && @lesson.job_photo.size == 1
      @lesson.remove_images!
    else
      @deleted_image = @new_job_photos.delete_at(@image_id)
      @deleted_image.try(:remove!)
      @lesson.update_attribute(:job_photo, @new_job_photos)
    end
  end

  def add_image
    @lesson_id = params[:lesson_id].to_i
    @image_id = params[:image_id].to_i
    @lesson = Lesson.find(@lesson_id)
    @new_job_photos = @lesson.job_photo
    @new_job_photos << params[:job_photo]
    @lesson.job_photo = @new_job_photos
    @lesson.save
  end

  def create_question
    @lesson = Lesson.find_by_token(params[:id])
    @question = @lesson.questions.build(question_params.merge(user_id: current_user.id))
    if @question.save
      @question = Question.new
    end
    redirect_to @lesson
  end

  def create_answer
    @question = Question.find(params[:id])
    @lesson = Lesson.find(@question.lesson_id)
    @answer = @question.build_answer(answer_params)
    if @answer.save
      @answer = Answer.new
    end
    redirect_to @lesson
  end

  def create_rsvp
    @lesson = Lesson.find_by_token(params[:id])
    @rsvp = @lesson.rsvps.build(rsvp_params.merge(attendee_id: current_user.id))
    if @rsvp.save
      @rsvp = Rsvp.new
    end
    redirect_to @lesson
  end

  def owner_cancel
    @lesson = Lesson.find(params[:id])
    @lesson.update_attribute(:owner_cancel_job, DateTime.current)
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find_by_token(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lesson_params
      params.require(:lesson).permit(:job_paid_datetime,:job_verified_datetime, :job_completed_datetime, :awardee_id, :contact_no, :timezone_offset, :date_completed, :datetime_completed, :date_awarded, :datetime_awarded, :title, :description, {tag: []}, :photo, {job_photo: []}, :bounty, :rsvps_attributes => [:endpoint, :p256dh, :auth, :attendee_id, :bid], :locations_attributes => [:id, :child_index, :block_no, :road_name, :building, :address, :postal, :lat, :lng, :unit_no, :country, :name])
    end

    def question_params
      params.require(:question).permit(:body)
    end

    def answer_params
      params.require(:answer).permit(:body)
    end

    def rsvp_params
      params.require(:rsvp).permit(:attended_lesson_id, :endpoint, :p256dh, :auth, :bid)
    end

    def ensure_canonical_url
      redirect_to Lesson.find(params[:id]) if @lesson.to_param != params[:id]
    end

    def check_signed_in
      redirect_to lesson_owner_path if signed_in?
    end

end
