class LessonsController < ApplicationController
  include LessonsHelper
  before_action :set_lesson, only: [:show, :edit, :destroy]
  #before_action :check_signed_in, only: [:index]
  before_action :authenticate_user!, only: [:show]
  before_action :needs_confirmation, only: [:new, :create_rsvp, :create_question]
  before_action :fill_up_profile_details, only: [:new, :create_rsvp, :create_question]
  before_action :ensure_canonical_url, only: [:show]
  helper_method :sort_column, :sort_direction


  # GET /lessons
  # GET /lessons.json
  def search
    if params[:search].present?
      if sort_direction.present?
        @direction = sort_direction
      else
        @direction = "desc"
      end
      if params[:search] == 'Full Sum'
        @lessons = Lesson.where(bounty_type: 3).order("bounty" + " " + @direction)
      elsif params[:search] == 'Bounty with Deposit'
        @lessons = Lesson.where(bounty_type: 2).order("bounty" + " " + @direction)
      elsif params[:search] == 'Bounty Only'
        @lessons = Lesson.where(bounty_type: 1).order("bounty" + " " + @direction)
      else
        @lessons = Lesson.search(params[:search], order: {sort_column => sort_direction})
      end
      if @lessons.blank?
        render :template => "lessons/_search_no_results"
      else
        respond_to do |format|
          format.html { render :template => "lessons/_search_results" }
        end
      end
    else
      @lessons = Lesson.where("datetime_awarded > ?", DateTime.current).where(awardee_id: nil).order(sort_column + " " + sort_direction)
    end
  end

  def index
    @lessons = Lesson.where("datetime_awarded > ?", DateTime.current).where(awardee_id: nil).order(sort_column + " " + sort_direction)
  end

  # GET /lessons/1
  # GET /lessons/1.json
  def show
    @rsvps = @lesson.rsvps.collect{ |rsvp| rsvp }.sort_by { |x| x.bid.to_i }
    @rsvp = Rsvp.new
    @bidders = @lesson.rsvps.collect{ |rsvp| rsvp.attendee_id}
    @invalid_bids = @lesson.rsvps.where("bid_withdraw IS NOT NULL")
    @bidders_cancelled = @invalid_bids.collect{ |rsvp| rsvp.attendee_id}
    @question = Question.new
    @questions = @lesson.questions
  end

  # GET /lessons/new
  def new
    @lesson = current_user.lessons.build
    @location = @lesson.locations.build
  end

  # GET /lessons/1/edit
  def edit
    if params[:repost].present?
      respond_to do |format|
        format.html {render :edit_repost}
      end
    else
      respond_to do |format|
        format.html {render :edit}
      end
    end
  end

  # POST /lessons
  # POST /lessons.json
  def create
    @lesson = current_user.lessons.build(lesson_params)
    respond_to do |format|
      if @lesson.save
        store_photos
        format.html { redirect_to @lesson }
        flash[:notice] = "<strong>Success! Your job is created!</strong><br>Just sit back and wait for bids!"
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
    if params[:repost].present?
      @new_lesson = current_user.lessons.create(lesson_params_repost)
      @lesson.job_repost_notification(@new_lesson)
      respond_to do |format|
        if @new_lesson.save
          format.html { redirect_to @new_lesson }
        end
      end
    else
      @lesson.assign_attributes(lesson_params)
      @owner = User.find(@lesson.organizer_id)
      if @lesson.awardee_id.present?
        @solver = Rsvp.find(@lesson.awardee_id).attendee
      end
      @changed_attribute = @lesson.changed
      respond_to do |format|
        if @lesson.save
          if params[:lesson][:job_photo].present?
            store_photos
          end
          if @changed_attribute == ["job_verified_datetime"]
            format.js { render 'review_owner.js.erb' }
          elsif @changed_attribute == ["dispute_details"]
            format.html { redirect_to(disputes_path) }
          elsif @changed_attribute == ["job_completed_datetime"]
            format.js { render 'review_solver.js.erb' }
          elsif @changed_attribute == ["solver_cancel_job"] or @changed_attribute == ["solver_agree_cancel"]
            format.html { redirect_to(lesson_solver_path) }
          elsif @changed_attribute == ["owner_cancel_job"]
            format.html { redirect_to(lesson_owner_path) }
          else
            format.html { redirect_to @lesson }
          end
        end
      end
    end
  end

  # DELETE /lessons/1
  # DELETE /lessons/1.json
  def destroy
    @lesson.destroy
    respond_to do |format|
      format.html { redirect_to lesson_owner_url, notice: 'Your job is successfully cancelled.<br>Create another Job!'  }
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

  def add_location_non
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

  def add_location_edit_non
    @lesson = current_user.lessons.build
    @location = @lesson.locations.build
    respond_to do |format|
      format.js {}
    end
  end

  def remove_image
    Photo.find(params[:image_id]).destroy
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

  def write_review_owner
    @lesson = Lesson.find(params[:id])
    @owner = User.find(@lesson.organizer_id)
    @solver = Rsvp.find(@lesson.awardee_id).attendee
    respond_to do |format|
      format.js { render 'review_owner.js.erb' }
    end
  end

  def repost_lesson
    @old_lesson = Lesson.find_by_token(params[:id])

    respond_to do |format|
      if @lesson.save
        store_photos
        format.html { redirect_to @lesson }
        flash[:notice] = "<strong>Success! Your job is reposted!</strong><br>Just sit back and wait for bids!"
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find_by_token(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lesson_params
      params.require(:lesson).permit(:dispute_details, :bounty_received_method, :bounty_type, :deposit, :repost, :owner_cancel_job, :solver_cancel_job, :owner_agree_cancel, :solver_agree_cancel,:job_paid_datetime,:job_verified_datetime, :job_completed_datetime, :awardee_id, :contact_no, :timezone_offset, :date_completed, :datetime_completed, :date_awarded, :datetime_awarded, :title, :description, {tag: []}, :photo, {job_photo: []}, :bounty, :rsvps_attributes => [:endpoint, :p256dh, :auth, :attendee_id, :bid], :locations_attributes => [:id, :child_index, :block_no, :road_name, :building, :address, :postal, :lat, :lng, :unit_no, :country, :name])
    end

    def lesson_params_repost
      params.require(:lesson).permit(:dispute_details, :bounty_received_method, :bounty_type, :deposit, :repost, :owner_cancel_job, :solver_cancel_job, :owner_agree_cancel, :solver_agree_cancel,:job_paid_datetime,:job_verified_datetime, :job_completed_datetime, :awardee_id, :contact_no, :timezone_offset, :date_completed, :datetime_completed, :date_awarded, :datetime_awarded, :title, :description, {tag: []}, :photo, {job_photo: []}, :bounty, :rsvps_attributes => [:endpoint, :p256dh, :auth, :attendee_id, :bid], :locations_attributes => [:child_index, :block_no, :road_name, :building, :address, :postal, :lat, :lng, :unit_no, :country, :name])
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
      begin
        redirect_to Lesson.find(params[:id]) if @lesson.to_param.first(13) != params[:id].first(13)
      rescue
        flash[:notice] = "Oopsy! We can't find the job you are looking for."
        redirect_to root_url
      end
    end

    def check_signed_in
      redirect_to lesson_owner_path if signed_in?
    end

    def store_photos
      if params[:lesson][:job_photo]
        photos = params[:lesson][:job_photo]
        photos.each{|photo| @lesson.photos.create(image: photo)}
      end
    end

    def sort_column
      %w[datetime_completed bounty datetime_awarded bounty_type].include?(params[:sort]) ? params[:sort] : "datetime_completed"
    end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
