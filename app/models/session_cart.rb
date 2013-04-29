class SessionCart

  def initialize(cart_contents)
    @cart_contents = cart_contents
    @cart = Cart.new(@cart_contents)
  end

  def total
    @cart.total
  end

  def count
    @cart.count
  end

  def empty?
    @cart.empty?
  end

  def each(&block)
    @cart.items.each(&block)
  end

  def remove_item(product_id)
    update_cart(@cart.remove_item(product_id))
  end

  def update(cart_data)
    update_cart(@cart.update(cart_data))
  end

  def destroy
    update_cart(@cart.destroy)
  end

private

  def update_cart(cart_data)
    @cart_contents = cart_data
  end
end