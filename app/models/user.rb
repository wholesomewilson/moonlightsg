class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :async,
         :omniauthable, omniauth_providers: [:google_oauth2]
         #omniauth_providers: [:google_oauth2, :facebook]
  # Association
  has_many :lessons, foreign_key: :organizer_id
  has_many :rsvps, foreign_key: :attendee_id, dependent: :destroy
  has_many :attended_lessons, through: :rsvps
  has_one :wallet, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :avatar, dependent: :destroy
  has_many :orderitems, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :testimonials

  #Serialise Ongoing Jobs and Completed Jobs
  serialize :ongoing_problems_owner, Array
  serialize :completed_problems_owner, Array
  serialize :ongoing_problems_solver, Array
  serialize :completed_problems_solver, Array

  #Create  wallet
  after_create :create_wallet

  def no_of_awarded_job(solver)
    self.lessons.map { |l| Rsvp.find(l.awardee_id).attendee == solver if l.awardee_id.present? }.count(true)
  end

  def no_of_reviews_given(owner)
    self.reviews.map { |r| r.reviewer_id == owner.id }.count(true)
  end

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

  def remove_from_completed_owner(id)
    @new_completed_problems_owner = completed_problems_owner
    @new_completed_problems_owner.delete(id)
    self.update_attribute(:completed_problems_owner, @new_completed_problems_owner)
  end

  def remove_from_completed_solver(id)
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

  def remember_me
    true
  end

  def self.from_omniauth(auth)
    @user = User.where(provider: auth.provider, uid: auth.uid).first
    if @user
      return @user
    else
      @registered_user = User.where(:email => auth.info.email).first
      if @registered_user
        return @registered_user
      else
        @user = User.create(
          provider: auth.provider,
          email: auth.info.email,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          password: Devise.friendly_token[0,20],
        )
      end
   end
  end

#protected
  def active_for_authentication?
   super and self.account_status.blank?
  end

  private
  def profile_pic_size_validation
    errors[:profile_pic] << "should be less than 500KB" if profile_pic.size > 0.5.megabytes
  end


end
