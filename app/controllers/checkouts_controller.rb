class CheckoutsController < ApplicationController
  before_filter :require_login, only: [ :buy_now ]
  before_filter :build_user

  def show
  end

  def create
    if @user.save
      order = create_order_and_pay(@user, current_cart)
      if order.valid?
        current_cart.destroy
        redirect_to order_path(order), notice: "Order submitted!"
      else
        redirect_to store_cart_path(current_store), notice: "Checkout failed."
      end
    else
      render action: :show
    end
  end

  def buy_now
    cart = Cart.new(params[:product_id] => '1')

    order = create_order_and_pay(current_user, cart.items)
    if order.valid?
      redirect_to order_path(order), notice: "Order submitted!"
    else
      redirect_to :back, notice: "Checkout failed."
    end
  end

private

  def build_user
    @user = if logged_in?
      current_user.attributes = params[:user]
      current_user
    else
      User.new_guest(params[:user])
    end

    @user.build_shipping_address if @user.shipping_address.nil?
    @user.build_billing_address if @user.billing_address.nil?
  end

  def create_order_and_pay(user, cart_items)
    Order.create_pending_order(user, cart_items).tap do |order|
      if order.valid?
        Payment.create_with_charge token: params[:stripeToken],
                                   price: order.total,
                                   email: order.user.email,
                                   order: order

        Mailer.order_confirmation(user, order).deliver
      end
    end
  end
end
