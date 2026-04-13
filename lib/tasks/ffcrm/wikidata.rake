# frozen_string_literal: true

namespace :ffcrm do
  desc 'Fetch account data from Wikidata'
  task wikidata: :environment do
    n = 0
    Account.where.not(wikidata_id: nil).find_each do |account|
      n += 1

      sleep(1) if (n % 10).zero? # Throttle requests to avoid hitting rate limits

      WikidataService.new(account).call

      puts "Updated account: #{account.name}"
    rescue StandardError => e
      puts "Error updating account #{account.name}: #{e.message}"
    end
  end
end
