class OrderitemsController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  def create
    @item = Item.find(params[:item_id])
    @orderitem = @item.orderitems.new(orderitem_params.merge(user_id: current_user.id))
    respond_to do |format|
      if @item.save
        format.html { redirect_to items_path }
        flash[:notice] = "Item added to your Cart!"
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @orderitem = Orderitem.find(params[:id])
    @orderitem.update(orderitem_params)
    respond_to do |format|
      if @orderitem.save
        format.html { redirect_to admin_path}
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

  private
  def orderitem_params
    params.require(:orderitem).permit(:quantity, :status, :reminder)
  end
end
