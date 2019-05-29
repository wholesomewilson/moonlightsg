class OrderitemsController < ApplicationController
  #before_action :authenticate_user!, only: [:create]

  def create
    if current_user.nil?
      session[:orderitem] = params
      flash[:notice] = "Please sign up or login to continue."
      redirect_to new_user_registration_path
    else
      @item = Item.find(params[:item_id])
      @orderitem = @item.orderitems.new(orderitem_params.merge(user_id: current_user.id))
      respond_to do |format|
        if @orderitem.save
          format.html { redirect_to items_path }
          flash[:notice] = "Item added to your Cart!"
          format.json { render :show, status: :created, location: @item }
        else
          format.html { render :new }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    @orderitem = Orderitem.find(params[:id])
    @orderitem.update(orderitem_params)
    respond_to do |format|
      if @orderitem.save
        if params[:orderitem][:quantity]
          format.html { redirect_to orders_path}
        else
          format.html { redirect_to admin_path}
        end
      end
    end
  end

  def destroy
    @orderitem = Orderitem.find(params[:id])
    @orderitem.destroy
    respond_to do |format|
      format.html { redirect_to orders_path, notice: 'Item removed!'  }
    end
  end

  def change_quantity
    @orderitem = Orderitem.find(params[:id])
    respond_to do |format|
      format.js { render 'change_quantity.js.erb'}
    end
  end

  private
  def orderitem_params
    params.require(:orderitem).permit(:quantity, :status, :reminder)
  end
end
