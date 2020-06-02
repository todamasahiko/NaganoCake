class Admin::ItemsController < ApplicationController
  def index
  end

  def show
  	@item = Item.find(params[:id])
  end

  def new
  end

  def edit
  	@item = Item.find(params[:id])
  end

  def update
  	@item = Item.find(params[:id])
  	if @item.update(item_params)
  	  redirect_to admin_item_path(@item.id)
  	else
  		render "edit"
  	end
  end

  private

  def item_params
  	params.require(:item).permit(:genre_id,:item_name,:unit_price_without_tax,:sale_status,:explanation,:image)
  end

end
