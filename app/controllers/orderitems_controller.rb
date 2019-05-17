class OrderitemsController < ApplicationController
  def create
    @item = Item.find(params[:item_id])
    @orderitem = @item.orderitems.new(orderitem_params.merge(user_id: current_user.id))
    respond_to do |format|
      if @item.save
        format.html { redirect_to items_path }
        link = ERB.new("<%= view_context.link_to 'Checkout Now', orders_path, :class=>'btn btn-continue' %>").result(binding)
        flash[:notice] = "Item added to your Cart!<br>" + link
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
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
    params.require(:orderitem).permit(:quantity)
  end
end
