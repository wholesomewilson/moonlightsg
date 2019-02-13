class Users::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]
before_action :fill_up_profile_details, only: [:create]


  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    if !current_user.confirmed?
      link = ERB.new("<%= view_context.link_to 'Resend Verification Email', user_confirmation_path(user: {:email => '#{current_user.email}'}), :method => :post, :class=>'btn btn-continue' %>").result(binding)
      flash[:welcome] = "Welcome back to Hootenanny, #{current_user.first_name}!<br>Your account is not verified yet.<br>" + link + "<br><strong>Only verified accounts are allowed to create Hootes!</strong>"
    else
      flash[:welcome] = "Welcome back to Hootenanny, #{current_user.first_name}!"
    end
  end

   #DELETE /resource/sign_out
   #def destroy
     #super
    # flash[:profile] = "Thank you for using Hootenanny!<br>Hope to see you real soon!"
   #end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
