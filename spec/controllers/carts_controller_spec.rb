require "rails_helper"
SimpleCov.start

RSpec.describe CartsController, type: :controller do
  let(:user) {create :user}
  let(:product) {create :product}
  let(:cart) {create :cart, user: user, product: product, quantity: 2}

  before do
    sign_in user
  end

  describe "GET #index" do
    before {get :index}

    it "assigns carts to @carts" do
      expect(assigns(:carts)).to_not be_nil
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "POST #create" do
    context "when user not signed in" do
      before do
        sign_out user
        post :create, params: {product_id: product.id}, format: :turbo_stream
      end

      it "show flash to login path" do
        expect(flash[:error]).to eq(I18n.t("flash.login_required"))
      end

      it "redirect to login page" do
        expect(response).to redirect_to(login_path)
      end
    end

    context "when product has stock" do
      before {post :create, params: {product_id: product.id}, format: :turbo_stream}

      it "creates a new cart" do
        expect(Cart.count).to eq(1)
      end

      it "assigns the correct product to the cart" do
        expect(assigns(:cart).product).to eq(product)
      end

      it "responds with a turbo stream" do
        expect(response.media_type).to eq Mime[:turbo_stream].to_s
      end
    end

    context "when product is out of stock" do
      let(:out_of_stock_product) {create(:product, stock: 0)}
      before {post :create, params: {product_id: out_of_stock_product.id}}

      it "does not create a new cart" do
        expect(Cart.count).to eq(0)
      end

      it "sets a flash error message" do
        expect(flash[:error]).to eq(I18n.t("flash.no_stock"))
      end

      it "redirects to the product page" do
        expect(response).to redirect_to(product_path(out_of_stock_product))
      end
    end
  end

  describe "PATCH #update" do
    context "when incrementing quantity" do
      before {patch :update, params: {id: cart.id, action_type: "increment"}, format: :turbo_stream}

      it "increments the cart quantity" do
        cart.reload
        expect(cart.quantity).to eq(2)
      end

      it "responds with a turbo stream" do
        expect(response.media_type).to eq Mime[:turbo_stream].to_s
      end
    end

    context "when decrementing quantity" do
      before {patch :update, params: {id: cart.id, action_type: "decrement"}, format: :turbo_stream}

      context "when decrementing quantity from 2 to 1" do
        it "decrements the cart quantity" do
          cart.reload
          expect(cart.quantity).to eq(1)
        end

        it "responds with a turbo stream" do
          expect(response.media_type).to eq Mime[:turbo_stream].to_s
        end
      end

      context "when decrementing quantity from 1 to 0" do
        let(:product_for_decrementing) {create(:product)}
        let(:cart_with_one_item) {create(:cart, user: user, product: product_for_decrementing, quantity: 1)}

        before {patch :update, params: {id: cart_with_one_item.id, action_type: "decrement"}, format: :turbo_stream}

        it "removes the cart when quantity reaches 0" do
          expect(Cart.exists?(cart_with_one_item.id)).to be_falsey
        end

        it "responds with a turbo stream" do
          expect(response.media_type).to eq Mime[:turbo_stream].to_s
        end
      end
    end
  end

  describe "PATCH #update_selection" do
    let!(:cart_item) { create(:cart, user: user, product: product, quantity: 2) }

    context "when updating selection" do
      before do
        sign_in user
      end

      it "responds to turbo_stream format" do
        patch :update_selection, params: { id: cart_item.id, is_checked: "true" }, format: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream].to_s
      end

      it "redirects to cart path when html format is requested" do
        patch :update_selection, params: { id: cart_item.id, is_checked: "true" }, format: :html
        expect(response).to redirect_to(carts_path)
      end
    end
  end


  describe "DELETE #destroy" do
    before {delete :destroy, params: {id: cart.id}, format: :turbo_stream}

    it "deletes the cart from the database" do
      expect(Cart.exists?(cart.id)).to be_falsey
    end

    it "responds with a turbo stream" do
      expect(response.media_type).to eq Mime[:turbo_stream].to_s
    end
  end
end
