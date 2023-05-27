# frozen_string_literal: true

# spec/support/active_storage.rb
RSpec.configure do |config|
  config.after(:each) do
    # Clear uploaded files after each test
    ActiveStorage::Blob.all.each(&:purge)
  end
end
