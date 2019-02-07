class LocationsController < ApplicationController
  #before_action :authenticate_user!

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    render :nothing => true
  end

end
