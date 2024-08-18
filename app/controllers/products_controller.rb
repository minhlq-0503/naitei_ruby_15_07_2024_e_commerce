class ProductsController < ApplicationController
  def show
    @product = Product.find_by id: params[:id]
    @cart = current_user&.carts&.find_by(product_id: @product.id)
    return if @product

    flash[:warning] = t "flash.not_found_product"
    redirect_to root_path
  end
end
