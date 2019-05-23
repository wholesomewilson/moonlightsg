class LocationsController < ApplicationController
  #before_action :authenticate_user!

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    render :nothing => true
  end

  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(location_params)
      flash[:success] = "Address is updated!"
      redirect_to orders_path
    else
      flash[:success] = "Something went wrong. Please try again. :("
      redirect_to orders_path
    end
  end

  private

    def location_params
      params.require(:location).permit(:id, :block_no, :road_name, :building, :postal, :unit_no)
    end
end
