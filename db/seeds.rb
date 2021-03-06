class LoadTestingStore
  attr_reader :load_store

  def initialize
    @load_store = Store.create!(name: 'Load', path: 'load', description: 'Load testing')
    load_store.update_attributes({status: 'offline'}, as: :uber)

    seed_categories(10)
    seed_products(10_000)
    seed_orders(20)
  end

  def seed_categories(num)
    num.times do |i|
      load_store.categories.create!(title: "Category ##{i.to_s}")
      puts "Category #{i} created"
    end
  end

  def seed_products(num)
    num.times do |i|
      puts "Load product ##{i}"
      begin
        title = Faker::Lorem.words(2).join(" ") + " " + i.to_s
        load_store.products.create!(title: title, description: 'None..', price: 1, status: 'active', category_ids: [rand(10) + 1])
      rescue
        retry
      end
    end
  end

  def seed_orders(num)
    num.times do |i|
      puts "Seeding order ##{i}"
      order = Order.create!(status: ::ORDER_STATUSES.sample,
                            user_id: 2)
      order.order_items.create!(product_id: rand(10_000) + 1,
                                unit_price: (75..150).to_a.sample,
                                quantity: rand(3) + 1)
    end
  end
end

class RealishStore
  attr_reader :store

  def initialize(store_params)
    @store = Store.create!(store_params)
    store.update_attributes({status: 'online'}, as: :uber)
    REDIS.zincrby('popular_stores', 1, @store.id)

    seed_categories(10)
    seed_products
    seed_orders(30)
  end

  def seed_products
    SEED_DATA['products'][store.path].each_with_index do |product_params, i|
      puts "Seeding product #{i+1} for store #{store.id}"
      image_params = product_params.delete('images')
      product = store.products.new(product_params)

      image_params.each do |image_param|
        product.images.new(data: URI.parse(image_param['url']))
      end

      product.save!
      REDIS.zincrby('popular_products', 1, product.id)
    end
  end

  def seed_categories(num)
    num.times do |i|
      title = Faker::Lorem.words(2).join(" ")
      store.categories.create!(title: title,
                               store_id: store.id)
      puts "Category #{title} created for Store #{store.id}"
    end
  end

  def seed_orders(num)
    num.times do |i|
      puts "Seeding order ##{i}"
      order = Order.create!(status: ::ORDER_STATUSES.sample,
                            user_id: 2)
      oi = order.order_items.create!(product_id: store.products.sample.id,
                                     unit_price: (75..150).to_a.sample,
                                     quantity: rand(3) + 1)
      oi.created_at += (rand(20) * -1).days
      oi.save!
    end
  end
end

# FLUSH REDIS
REDIS.flushall

# LOAD SEED DATA, SETUP CONSTANTS
SEED_DATA = YAML.load_file('db/seeds.yml')
ORDER_STATUSES = ['pending', 'shipped', 'cancelled', 'returned', 'paid']

# THE USUAL SUSPECTS / UBERS
user1 = User.create(full_name: "Jeff", email: "demoXX+jeff@jumpstartlab.com", password: "password", display_name: "j3")
user1.uber_up
Collection.create(name: "favorites", user: user1)

user2 = User.create(full_name: "Steve Klabnik", email: "demoXX+steve@jumpstartlab.com", password: "password", display_name: "SkrilleX")
user2.uber_up
Collection.create(name: "favorites", user: user2)

# CREATE LOAD TESTING STORE
LoadTestingStore.new

# CREATE REAL-ISH STORES
SEED_DATA['stores'].each do |store_params|
  RealishStore.new(store_params)
end

OrderItem.all.each do |i|
  puts "Updating date for order item #{i.id}"
  i.created_at += (rand(20) * -1).days
  i.save
end
