class CartsController < ApplicationController
  before_action :find_cart_item, only: %i(update destroy)
  def index
    @pagy, @carts = pagy(
      current_user.carts.includes(:product),
      items: Settings.page_10
    )
  end

  def create
    @cart = current_user
            .carts
            .find_or_initialize_by(product_id: params[:product_id])
    @cart.quantity ||= 0
    @cart.quantity += 1

    if @cart.save
      respond_to do |format|
        format.turbo_stream
        format.html{redirect_to product_path @cart.product}
      end
    else
      flash[:warning] = t "flash.add_to_cart_failed"
    end
  end

  def update
    if params[:action_type] == "increment"
      @cart.update(quantity: @cart.quantity + 1)
    elsif params[:action_type] == "decrement"
      @cart.update(quantity: @cart.quantity - 1)
      @cart.destroy if @cart.quantity <= 0
    end

    respond_to do |format|
      format.turbo_stream
      format.html{redirect_to product_path @cart.product}
    end
  end

  def destroy
    @cart.destroy
    respond_to do |format|
      format.turbo_stream
      format.html{redirect_to product_path @cart.product}
    end
  end

  private

  def find_cart_item
    @cart = current_user.carts.find_by(product_id: params[:product_id])
  end
end
