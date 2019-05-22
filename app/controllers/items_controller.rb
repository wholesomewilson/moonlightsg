class ItemsController < ApplicationController
  before_filter :authorize_admin, only: [:create, :new, :edit, :update, :destroy]
  before_action :set_item, only: [:show, :edit, :destroy, :update]
  before_action :authenticate_user!, only: [:show]

  def index
    @items = Item.where.not(brand: "Eureka").where.not(brand: "Merries").sort_by { |x| x.brand }
    @countdown = DateTime.parse("#{'20-05-2019'} #{'00'}:#{'00'}#{'AM'}")
    @popcorn_6 = Item.where(brand: "Eureka").where(price_my: 6.7).first
    @popcorn_7 = Item.where(brand: "Eureka").where(price_my: 7.5)
    @diaper = Item.where(brand: "Merries").first
  end

  def show
    @orderitem = @item.orderitems.build
    @eureka_6 = Item.all.where(brand: "Eureka").where(price_my: 6.7).sort_by{ |x| x.name }
    @eureka_7 = Item.all.where(brand: "Eureka").where(price_my: 7.5).sort_by{ |x| x.name }
    @merries = Item.all.where(brand: "Merries").sort_by{ |x| x.id }
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
