class TestimonialsController < ApplicationController
  before_action :authenticate_user!
  def index
    @testimonials = current_user.testimonials.all
    @testimonial = current_user.testimonials.build
  end

  def create
    @testimonial = current_user.testimonials.build(testimonial_params)
    respond_to do |format|
      if @testimonial.save
        flash[:notice] = "Thank you so much for your testimonial!<br>We will work on the feedback and improve our services! :)"
        format.html {redirect_to testimonials_path}
      end
    end
  end

private
  def testimonial_params
    params.require(:testimonial).permit(:body, :improve)
  end

end
