class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?
    if successfully_sent?(resource)
      flash[:forget] = "We've sent you an email for the instruction to reset your password. :)"
      redirect_to root_path
    else
      flash[:forget] = "Something went wrong :(<br>Please try again."
      redirect_to forgetpassword_path
    end
  end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
   def update
     self.resource = resource_class.reset_password_by_token(resource_params)
      yield resource if block_given?
      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        if Devise.sign_in_after_reset_password
          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message!(:notice, flash_message)
          resource.after_database_authentication
          sign_in(resource_name, resource)
        else
          set_flash_message!(:notice, :updated_not_active)
        end
        flash[:forget] = "Your password is changed successfully!"
        redirect_to root_path
      else
        flash[:forget] = "Something went wrong :(<br>Please try again."
        redirect_to forgetpassword_path
      end
   end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
