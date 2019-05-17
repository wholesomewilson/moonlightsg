class ItemsController < ApplicationController
  before_filter :authorize_admin, only: [:create, :new, :edit, :update, :destroy]
  before_action :set_item, only: [:show, :edit, :destroy, :update]

  def index
    @items = Item.all
    @countdown = DateTime.parse("#{'20-05-2019'} #{'00'}:#{'00'}#{'AM'}")
  end

  def show
    @orderitem = @item.orderitems.build
    @eureka = Item.all.where(brand: "Eureka")
    @merries = Item.all.where(brand: "Merries")
    @countdown = DateTime.parse("#{'20-05-2019'} #{'00'}:#{'00'}#{'AM'}")
  end

  def create
    @item = Item.new(item_params)
    respond_to do |format|
      if @item.save
        format.html { redirect_to items_path }
        flash[:notice] = "Success!"
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @item = Item.new
  end

  def edit
    respond_to do |format|
      format.html {render :edit}
    end
  end

  def update
    if @item.update_attributes(item_params)
      flash[:success] = "Updated"
      redirect_to @item
    else
      render 'edit'
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_path, notice: 'Item is destroyed!'  }
    end
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:name, :brand, :tag, :price_sg, :price_my, :item_photo, :description)
    end
end
