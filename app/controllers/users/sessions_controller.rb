class Users::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    if !current_user.confirmed?
      link = ERB.new("<%= view_context.link_to 'Resend Verification Email', user_confirmation_path(user: {:email => '#{current_user.email}'}), :method => :post, :class=>'btn btn-continue' %>").result(binding)
      flash[:notice] = "Welcome back to Moonlight!<br>Your account is not verified yet.<br>" + link + "<br><strong>Only verified accounts and updated profiles<br>are allowed to create or bid for jobs!</strong>"
    else
      flash[:notice] = "Welcome back to Moonlight, #{current_user.first_name}!"
    end
  end

   #DELETE /resource/sign_out
   #def destroy
     #super
   #end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
