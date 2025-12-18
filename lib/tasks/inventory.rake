# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc "Seed inventory data (samples and bundles)"
    task inventory: :environment do
      require Rails.root.join('db/seeds/inventory')
    end
  end
end

namespace :inventory do
  desc "Clear all inventory data (samples and bundles)"
  task clear: :environment do
    puts "Clearing inventory data..."
    Sample.destroy_all
    Bundle.destroy_all
    puts "Done! Cleared all samples and bundles."
  end

  desc "Reset inventory data (clear and re-seed)"
  task reset: :environment do
    Rake::Task["inventory:clear"].invoke
    Rake::Task["db:seed:inventory"].invoke
  end

  desc "Show inventory statistics"
  task stats: :environment do
    puts "\n" + "=" * 50
    puts "Inventory Statistics"
    puts "=" * 50
    puts "Bundles: #{Bundle.count}"
    puts "Samples: #{Sample.count}"
    puts "  - Available: #{Sample.available.count}"
    puts "  - Checked Out: #{Sample.checked_out.count}"
    puts "  - Reserved: #{Sample.where(status: 'reserved').count}"
    puts "  - Discontinued: #{Sample.where(status: 'discontinued').count}"
    puts "  - Fire Sale: #{Sample.fire_sale.count}"
    puts "\nTop Brands:"
    Sample.group(:brand).count.sort_by { |_, v| -v }.first(10).each do |brand, count|
      puts "  #{brand}: #{count}"
    end
    puts "\nLocations:"
    Sample.group(:location).count.each do |location, count|
      puts "  #{location}: #{count}"
    end
    puts "=" * 50
  end
end
