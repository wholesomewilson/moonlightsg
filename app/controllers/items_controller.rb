class ItemsController < ApplicationController
  before_filter :authorize_admin, only: [:create, :new, :edit, :update, :destroy]
  before_action :set_item, only: [:show, :edit, :destroy, :update]
  before_action :set_countdown, only: [:index, :show]
  before_action :set_boost_date, only: [:index]

  def index
    @items = Item.where(status: nil).where.not(brand: "Eureka").where.not(brand: "Merries").where.not(brand: "Drypers").where.not(brand: "Huggies").where.not(brand: "Famous Amos").where.not(brand: "Moist Diane Botanical").where.not(brand: "Moist Diane Extra").where.not(brand: "Head & Shoulders").where.not(brand: "Old Town").where.not(brand: "MamyPoko").where.not(brand: "Tena").where.not(brand: "Maybelline").where.not(brand: "Clariti").where.not(brand: "PappaRich").where.not(brand: "PetPet").where.not(brand: "Huggies Little Swimmer").where.not(brand: "Drypers Wee Wee Dry").sort_by { |x| x.brand }
    @popcorn_6 = Item.where(status: nil).where(brand: "Eureka").first
    @merries = Item.where(status: nil).where(brand: "Merries").first
    @drypers = Item.where(status: nil).where(brand: "Drypers").first
    @huggies = Item.where(status: nil).where(brand: "Huggies").first
    @famous = Item.where(status: nil).where(brand: "Famous Amos").first
    @moistbo = Item.where(status: nil).where(brand: "Moist Diane Botanical").first
    @moistex = Item.where(status: nil).where(brand: "Moist Diane Extra").first
    @head = Item.where(status: nil).where(brand: "Head & Shoulders").first
    @old = Item.where(status: nil).where(brand: "Old Town").first
    @mamy = Item.where(status: nil).where(brand: "MamyPoko").first
    @tena = Item.where(status: nil).where(brand: "Tena").first
    @maybelline = Item.where(status: nil).where(brand: "Maybelline").last
    @clariti = Item.where(status: nil).where(brand: "Clariti").first
    @pappa = Item.where(status: nil).where(brand: "PappaRich").first
    @pet = Item.where(status: nil).where(brand: "PetPet").first
    @hswim = Item.where(status: nil).where(brand: "Huggies Little Swimmer").first
    @drypersw = Item.where(status: nil).where(brand: "Drypers Wee Wee Dry").first
    @sales = Order.where(['created_at > ?', @boost_date]).map { |x| x.amount }.sum + 304
    @more = 500 - @sales
    @progress = @sales.to_d / 500 * 100
  end

  def show
    @orderitem = @item.orderitems.build
    @eureka_6 = Item.where(status: nil).where(brand: "Eureka").sort_by{ |x| x.name }
    @merries = Item.where(status: nil).where(brand: "Merries").sort_by{ |x| x.id }
    @drypers = Item.where(status: nil).where(brand: "Drypers").sort_by{ |x| x.id }
    @huggies = Item.where(status: nil).where(brand: "Huggies").sort_by{ |x| x.id }
    @famous = Item.where(status: nil).where(brand: "Famous Amos").sort_by{ |x| x.id }
    @moistbo = Item.where(status: nil).where(brand: "Moist Diane Botanical").sort_by{ |x| x.id }
    @moistex = Item.where(status: nil).where(brand: "Moist Diane Extra").sort_by{ |x| x.id }
    @head = Item.where(status: nil).where(brand: "Head & Shoulders").sort_by{ |x| x.id }
    @old = Item.where(status: nil).where(brand: "Old Town").sort_by{ |x| x.id }
    @mamy = Item.where(status: nil).where(brand: "MamyPoko").sort_by{ |x| x.id }
    @tena = Item.where(status: nil).where(brand: "Tena").sort_by{ |x| x.id }
    @maybelline = Item.where(status: nil).where(brand: "Maybelline").sort_by{ |x| x.id }
    @clariti = Item.where(status: nil).where(brand: "Clariti").sort_by{ |x| x.id }
    @pappa = Item.where(status: nil).where(brand: "PappaRich").sort_by{ |x| x.id }
    @pet = Item.where(status: nil).where(brand: "PetPet").sort_by{ |x| x.id }
    @hswim = Item.where(status: nil).where(brand: "Huggies Little Swimmer").sort_by{ |x| x.id }
    @drypersw = Item.where(status: nil).where(brand: "Drypers Wee Wee Dry").sort_by{ |x| x.id }
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

  def product_info
    @item = Item.find(params[:id])
    respond_to do |format|
      format.js { render "product_info.js.erb"  }
    end
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:name, :brand, :tag, :price_sg, :price_my, :item_photo, :description, :status)
    end

    def set_countdown
      @countdown = DateTime.parse("#{'26-06-2019'} #{'00'}:#{'00'}#{'AM'}")
    end

    def set_boost_date
      @boost_date = DateTime.parse("#{'19-06-2019'} #{'00'}:#{'00'}#{'AM'}")
    end
end
