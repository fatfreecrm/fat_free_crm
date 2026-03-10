# frozen_string_literal: true

class Rack::Attack
  ### Configure Cache ###

  # If you don't want to use Rails.cache (e.g. it's Redis),
  # you can configure Rack::Attack to use another store.
  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single IP makes more than 5 requests/minute to the devise routes,
  # return a 429 Too Many Requests response.
  throttle('devise/ip', limit: 5, period: 1.minute) do |req|
    if req.path.start_with?('/users') && req.post?
      req.ip
    end
  end

  ### Custom Response ###

  # By default, Rack::Attack returns an HTTP 429 Too Many Requests response
  # with an empty body.
  #
  # You can customize the response by setting self.throttled_responder.
  self.throttled_responder = lambda do |_env|
    [429, { 'Content-Type' => 'text/plain' }, ["Too Many Requests\n"]]
  end
end
