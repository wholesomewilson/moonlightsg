class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :store_current_location, :unless => :devise_controller?
  before_filter :set_conversations
  before_filter :set_swifttimer

 protected

  rescue_from ActionController::RoutingError do |exception|
    flash[:error] = "Oopsy! The page which you're looking for does not exist."
    redirect_to root_url
  end

 def configure_permitted_parameters
   devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :contact_number, :company, :website, :address, :address_2, :city, :country, :postal_code, :gender, :birth_date, :age) }
   devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:username, :email, :password, :remember_me) }
   devise_parameter_sanitizer.permit(:account_update) {|u| u.permit(:country_code_contact, :account_status, :username, :email, :password, :password_confirmation, :current_password, :first_name, :last_name, :contact_number, :profile_pic, :profile_pic_cache, :remove_profile_pic, :endpoint, :p256dh, :auth) }
 end

 def needs_confirmation
   if user_signed_in?
    if !current_user.confirmed?
      redirect_to root_path
      link = ERB.new("<%= view_context.link_to 'Resend Verification Email', user_confirmation_path(user: {:email => '#{current_user.email}'}), :method => :post, :class=>'btn btn-continue' %>").result(binding)
      flash[:notice] = "<strong>Only verified accounts and updated profiles<br>are allowed to create or bid for jobs!</strong><br>Did you miss out the verification email sent to you?<br>Check your Spam/Junk folder too!<br>" + link
    end
  else
    redirect_to login_path
    flash[:notice] = "Please login to continue!"
  end
 end

 def fill_up_profile_details
  if user_signed_in?
    if current_user.first_name.blank? or current_user.last_name.blank? or current_user.contact_number.blank? or current_user.avatar.blank?
      redirect_to about_yourself_path
      flash[:notice] = "<strong>Please complete your profile first!</strong>"
    end
  else
    redirect_to login_path
    flash[:notice] = "<strong>Please login to continue!</strong>"
  end
 end

 def set_conversations
  if user_signed_in?
    @conversations = Conversation.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
  end
 end

 def set_swifttimer
   if user_signed_in?
     @orderitems = current_user.orderitems.where(["status IS ? or status = ?", nil, '0']).sort_by {|x| x.created_at}
     if @orderitems.present?
       @gswifttimer = @orderitems.last.created_at + 15.minutes + 55.seconds
     else
       @gswifttimer = DateTime.parse("#{'12-06-2001'} #{'00'}:#{'00'}#{'AM'}")
     end
   end
 end

private

 def store_current_location
   store_location_for(:user, request.url)
 end

 def after_sign_out_path_for(resource)
   root_path
 end

 def after_sign_in_path_for(resource)
   if session[:orderitem].present?
     @orderitem = Item.find(session[:orderitem]["item_id"]).orderitems.create(session[:orderitem]["orderitem"].merge(user_id: current_user.id))
     session[:orderitem] = nil
     flash[:notice] = "Item added to your Cart!"
     items_path
   else
     stored_location_for(resource) || request.env['omniauth.origin'] || items_path
   end
 end

 def authorize_admin
   redirect_to(root_path) unless current_user && current_user.admin?
 end
end
