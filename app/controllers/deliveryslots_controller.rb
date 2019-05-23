class DeliveryslotsController < ApplicationController
  include DeliveryslotsHelper

  def update
    @deliveryslot = Deliveryslot.find(params[:id])
    if @deliveryslot.update_attributes(deliveryslot_params)
      flash[:success] = "Delivery Date and Time is updated!"
      redirect_to orders_path
    else
      flash[:success] = "Something went wrong. Please try again. :("
      redirect_to orders_path
    end
  end

  def change_date
    @deliveryslot = Deliveryslot.find(params[:id])
    respond_to do |format|
      format.js { render 'change_date.js.erb'}
    end
  end

  private

  def deliveryslot_params
    params.require(:deliveryslot).permit(:id, :date, :timeslot_id)
  end

end
