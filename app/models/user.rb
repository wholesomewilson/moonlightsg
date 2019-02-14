class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :async

  # Association
  has_many :lessons, foreign_key: :organizer_id
  has_many :rsvps, foreign_key: :attendee_id, dependent: :destroy
  has_many :attended_lessons, through: :rsvps
  has_one :wallet, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :avatar, dependent: :destroy

  #Serialise Ongoing Jobs and Completed Jobs
  serialize :ongoing_problems_owner, Array
  serialize :completed_problems_owner, Array
  serialize :ongoing_problems_solver, Array
  serialize :completed_problems_solver, Array

  #Create  wallet
  #after_create :create_wallet

  after_create :create_wallet

  def create_wallet
    Wallet.create(user_id: self.id)
    # Maybe check if profile gets created and raise an error
    #  or provide some kind of error handling
  end

  # Background application
  def send_devise_notification(notification, *args)
    ConfirmationMailer.send(notification, self, *args).deliver_later
  end

  def send_confirmation_instructions
    super
  end

  def after_confirmation
    SendWelcomeMailJob.perform_later(self)
  end

  def add_to_ongoing_problems_owner(id)
    if ongoing_problems_owner.blank?
      @new_ongoing_problems_owner = Array.new
      @new_ongoing_problems_owner.push(id)
      self.update_attribute(:ongoing_problems_owner, @new_ongoing_problems_owner)
    else
      @new_ongoing_problems_owner = ongoing_problems_owner
      @new_ongoing_problems_owner.push(id)
      self.update_attribute(:ongoing_problems_owner, @new_ongoing_problems_owner)
    end
  end

  def add_to_ongoing_problems_solver(id)
    if ongoing_problems_solver.blank?
      @new_ongoing_problems_solver = Array.new
      @new_ongoing_problems_solver.push(id)
      self.update_attribute(:ongoing_problems_solver, @new_ongoing_problems_solver)
    else
      @new_ongoing_problems_solver = ongoing_problems_solver
      @new_ongoing_problems_solver.push(id)
      self.update_attribute(:ongoing_problems_solver, @new_ongoing_problems_solver)
    end
  end

  def remove_from_ongoing_and_add_to_completed_problems_owner(id)
    @new_ongoing_problems_owner = ongoing_problems_owner
    @new_ongoing_problems_owner.delete(id)
    self.update_attribute(:ongoing_problems_owner, @new_ongoing_problems_owner)
    if completed_problems_owner.blank?
      @new_completed_problems_owner = Array.new
      @new_completed_problems_owner.push(id)
      self.update_attribute(:completed_problems_owner, @new_completed_problems_owner)
    else
      @new_completed_problems_owner = completed_problems_owner
      @new_completed_problems_owner.push(id)
      self.update_attribute(:completed_problems_owner, @new_completed_problems_owner)
    end
  end

  def remove_from_ongoing_and_add_to_completed_problems_solver(id)
    @new_ongoing_problems_solver = ongoing_problems_solver
    @new_ongoing_problems_solver.delete(id)
    self.update_attribute(:ongoing_problems_solver, @new_ongoing_problems_solver)
    if completed_problems_solver.blank?
      @new_completed_problems_solver = Array.new
      @new_completed_problems_solver.push(id)
      self.update_attribute(:completed_problems_solver, @new_completed_problems_solver)
    else
      @new_completed_problems_solver = completed_problems_solver
      @new_completed_problems_solver.push(id)
      self.update_attribute(:completed_problems_solver, @new_completed_problems_solver)
    end
  end

  def remove_from_ongoing_and_completed(id)
    @new_ongoing_problems_owner = ongoing_problems_owner
    @new_ongoing_problems_owner.delete(id)
    self.update_attribute(:ongoing_problems_owner, @new_ongoing_problems_owner)
    @new_ongoing_problems_solver = ongoing_problems_solver
    @new_ongoing_problems_solver.delete(id)
    self.update_attribute(:ongoing_problems_solver, @new_ongoing_problems_solver)
    @new_completed_problems_owner = completed_problems_owner
    @new_completed_problems_owner.delete(id)
    self.update_attribute(:completed_problems_owner, @new_completed_problems_owner)
    @new_completed_problems_solver = completed_problems_solver
    @new_completed_problems_solver.delete(id)
    self.update_attribute(:completed_problems_solver, @new_completed_problems_solver)
  end

  def rating_solver_stars
    rating_solver.round
  end

  def rating_owner_stars
    rating_owner.round
  end

  def blank_stars_owner
    5 - self.rating_owner_stars.to_i
  end

  def blank_stars_solver
    5 - self.rating_solver_stars.to_i
  end

  def number_of_reviews_solver
    Review.where(user_id: id).where("rating_solver IS NOT NULL").count
  end

  def number_of_reviews_owner
    Review.where(user_id: id).where("rating_owner IS NOT NULL").count
  end

  def update_rating_solver(rating)
    if rating_solver == 0
      self.update_attribute(:rating_solver, rating)
    else
      @number_of_reviews_new = self.number_of_reviews_solver
      @number_of_reviews_old = @number_of_reviews_new - 1
      @new_rating = (rating_solver * @number_of_reviews_old + rating) / @number_of_reviews_new
      self.update_attribute(:rating_solver, @new_rating)
    end
  end

  def update_rating_owner(rating)
    if rating_owner == 0
      self.update_attribute(:rating_owner, rating)
    else
      @number_of_reviews_new = self.number_of_reviews_owner
      @number_of_reviews_old = @number_of_reviews_new - 1
      @new_rating = (rating_owner * @number_of_reviews_old + rating) / @number_of_reviews_new
      self.update_attribute(:rating_solver, @new_rating)
    end
  end

#protected
  def active_for_authentication?
   true
  end

  private
  def profile_pic_size_validation
    errors[:profile_pic] << "should be less than 500KB" if profile_pic.size > 0.5.megabytes
  end


end
