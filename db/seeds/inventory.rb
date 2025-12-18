# frozen_string_literal: true

# Inventory Seed Data
# Run with: rails db:seed:inventory or include in main seeds.rb

puts "Seeding inventory data..."

# Ensure we have at least one user
user = User.first
unless user
  puts "Creating demo user..."
  user = User.create!(
    username: 'demo',
    email: 'demo@example.com',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Demo',
    last_name: 'User',
    admin: true
  )
end

# Brand names for samples
BRANDS = [
  'Apple', 'Samsung', 'Nike', 'Adidas', 'Sony', 'LG', 'Dyson', 'Bose',
  'Canon', 'Nikon', 'Dell', 'HP', 'Lenovo', 'Logitech', 'Anker',
  'Beats', 'JBL', 'Philips', 'Panasonic', 'Xiaomi', 'OnePlus', 'Fitbit',
  'GoPro', 'DJI', 'Fujifilm', 'Razer', 'SteelSeries', 'Corsair'
].freeze

# Product categories for sample names
PRODUCT_CATEGORIES = {
  'Electronics' => ['Wireless Earbuds', 'Bluetooth Speaker', 'Smart Watch', 'Tablet', 'Laptop Stand', 'USB Hub', 'Power Bank', 'Webcam', 'Mouse', 'Keyboard'],
  'Fashion' => ['Running Shoes', 'Sneakers', 'Hoodie', 'T-Shirt', 'Backpack', 'Cap', 'Sunglasses', 'Watch Band', 'Wallet', 'Belt'],
  'Home' => ['Vacuum Cleaner', 'Air Purifier', 'Smart Plug', 'LED Bulb', 'Desk Lamp', 'Fan', 'Humidifier', 'Coffee Maker', 'Blender', 'Toaster'],
  'Sports' => ['Yoga Mat', 'Resistance Bands', 'Jump Rope', 'Foam Roller', 'Water Bottle', 'Gym Bag', 'Fitness Tracker', 'Dumbbell Set', 'Exercise Ball', 'Pull-up Bar'],
  'Beauty' => ['Face Mask', 'Skincare Set', 'Hair Dryer', 'Straightener', 'Makeup Mirror', 'Nail Kit', 'Essential Oils', 'Face Roller', 'Lip Balm Set', 'Perfume']
}.freeze

# Locations
LOCATIONS = ['Warehouse A', 'Warehouse B', 'Showroom', 'Office', 'Storage Unit 1', 'Storage Unit 2', 'Partner Location'].freeze

puts "Creating bundles..."
bundles = []

15.times do |i|
  bundle = Bundle.find_or_create_by!(
    qr_code: "BUNDLE-#{SecureRandom.hex(4).upcase}-#{i + 1}"
  ) do |b|
    location = LOCATIONS.sample
    b.user = user
    b.name = "#{FFaker::Product.product_name} Collection #{i + 1}"
    b.description = FFaker::Lorem.paragraph
    b.location = location
    b.access = 'Public'
  end
  bundles << bundle
  print "."
end
puts "\nCreated #{bundles.count} bundles"

puts "Creating samples..."
samples_created = 0

100.times do |i|
  brand = BRANDS.sample
  category = PRODUCT_CATEGORIES.keys.sample
  product = PRODUCT_CATEGORIES[category].sample
  original_price = rand(19.99..499.99).round(2)
  discount = rand(0.1..0.6)
  best_price = (original_price * (1 - discount)).round(2)

  sample = Sample.find_or_create_by!(
    qr_code: "SAMPLE-#{SecureRandom.hex(4).upcase}-#{i + 1}"
  ) do |s|
    s.user = user
    s.bundle = bundles.sample if rand < 0.7 # 70% chance of being in a bundle
    s.name = "#{brand} #{product}"
    s.brand = brand
    s.location = LOCATIONS.sample
    s.sku = "SKU-#{brand[0..2].upcase}-#{rand(10000..99999)}"
    s.tiktok_affiliate_link = "https://www.tiktok.com/@shop/product/#{SecureRandom.hex(8)}"
    s.has_fire_sale = rand < 0.2 # 20% chance of fire sale
    s.best_price = best_price
    s.original_price = original_price
    s.status = %w[available available available available checked_out reserved].sample # 66% available
    s.description = "#{FFaker::Lorem.sentence} Perfect for #{category.downcase} enthusiasts."
    s.notes = rand < 0.3 ? FFaker::Lorem.sentence : nil
    s.access = 'Public'

    # Set checkout info if checked out
    if s.status == 'checked_out'
      s.checked_out_at = rand(1..30).days.ago
      s.checked_out_by = user.id
    end
  end

  samples_created += 1
  print "." if (i + 1) % 10 == 0
end
puts "\nCreated #{samples_created} samples"

# Add some tags to samples
puts "Adding tags to samples..."
Sample.all.each do |sample|
  tags = []
  tags << sample.brand.downcase if sample.brand
  tags << 'fire-sale' if sample.has_fire_sale
  tags << 'popular' if rand < 0.3
  tags << 'new-arrival' if rand < 0.2
  tags << 'trending' if rand < 0.15
  sample.update(tag_list: tags.join(', '))
end
puts "Tags added"

# Summary
puts "\n" + "=" * 50
puts "Inventory Seed Complete!"
puts "=" * 50
puts "Bundles: #{Bundle.count}"
puts "Samples: #{Sample.count}"
puts "  - Available: #{Sample.available.count}"
puts "  - Checked Out: #{Sample.checked_out.count}"
puts "  - Fire Sale: #{Sample.fire_sale.count}"
puts "=" * 50
