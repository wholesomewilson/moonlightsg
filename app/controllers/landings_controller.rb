class LandingsController < ApplicationController
  def index
    @countdown = DateTime.parse("#{'12-06-2019'} #{'00'}:#{'00'}#{'AM'}")
    @testimonials = Testimonial.all
  end

  def blog

  end

  def fees

  end

  def about_us

  end
end
