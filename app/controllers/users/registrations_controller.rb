class Users::RegistrationsController < Devise::RegistrationsController
  include DateHelper
# before_action :configure_sign_up_params, only: [:create]
# before_action :configure_account_update_params, only: [:update]
prepend_before_action :authenticate_scope!, only: [:edit, :update, :destroy]

#before_action :set_lesson, only: [:lesson_attended, :lesson_organized]

def about_yourself
  self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
end

def contact_info
  self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
end

def close_account
  self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
end

def lesson_solver
  if user_signed_in?
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    @lesson_solver_ongoing = Lesson.find(current_user.ongoing_problems_solver).sort_by { |x| x.datetime_completed }
    @lesson_solver_completed = Lesson.find(current_user.completed_problems_solver).sort_by { |x| x.created_at }.reverse!
    @dispute = Dispute.new
  else
    redirect_to login_path
  end
end

def lesson_owner
  if user_signed_in?
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    @lesson_owner_ongoing = Lesson.find(current_user.ongoing_problems_owner).sort_by { |x| x.datetime_completed }
    @lesson_owner_completed = Lesson.find(current_user.completed_problems_owner).sort_by { |x| x.created_at }.reverse!
    @dispute = Dispute.new
  else
    redirect_to login_path
  end
end

def wallet
  @wallet = current_user.wallet
  @transactions = @wallet.transactions.sort_by {|t| t.created_at}.reverse!
  @transaction = Transaction.new
  self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
  @user = User.find(current_user.id)
end

def create_transaction
  @wallet = Wallet.find(params[:id])
  @transaction = @wallet.transactions.build(transaction_params)
  if @transaction.save
    @wallet.update_wallet_balance(@transaction)
    @transaction = Transaction.new
  end
  redirect_to wallet_path
end

#GET /resource/sign_up
 #def create
#  super
# end

# PUT /resource
def update
  @user = User.find(current_user.id)
  account_update_params = devise_parameter_sanitizer.sanitize(:account_update)
  if params[:user][:password]
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      flash[:notice] = "Password is updated successfully!"
      redirect_to password_path
    else
      flash[:notice] = "Current password is incorrect. Please try again."
      redirect_to password_path
    end
  else
    @update = update_resource(@user, account_update_params)
    if params[:user][:profile_pic]
      store_photos
      if @user.save
        respond_to do |format|
          format.js { render 'upload_image_complete.js.erb'}
        end
      end
    end
    if params[:user][:first_name] || params[:user][:last_name] || params[:user][:contact_number]
      redirect_to root_path
      if current_user.confirmed?
        flash[:notice] = "Your profile is updated successfully! You can post or bid for a job now!"
      else
        link = ERB.new("<%= view_context.link_to 'Resend Verification Email', user_confirmation_path(user: {:email => '#{current_user.email}'}), :method => :post, :class=>'btn btn-continue' %>").result(binding)
        flash[:notice] = "Your profile is updated successfully!<br>Please verify your account via the email sent to you.<br>Did you miss out the verification email sent to you? Please check the Spam/Junk folder too!<br>" + link
      end
    end
    if params[:user][:account_status] == '1'
      if @user.save
        respond_to do |format|
          flash[:notice] = "Your account is cancelled. We are sad to see you go.<br>Let us know what could we have done better."
          format.html { redirect_to root_path }
        end
      end
    end
  end
end

private

def set_lesson
  @lessons = Lesson.all
end

def transaction_params
  params.require(:transaction).permit(:amount, :transaction_type)
end

def store_photos
  photo = params[:user][:profile_pic]
  @user.create_avatar(image: photo)
end

def user_params
  params.require(:user).permit(:password, :password_confirmation, :current_password)
end


  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end
  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    about_yourself_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   about_yourself_path
  # end
end
