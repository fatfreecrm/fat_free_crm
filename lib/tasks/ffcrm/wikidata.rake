# frozen_string_literal: true

namespace :ffcrm do
  desc 'Fetch account data from Wikidata'
  task wikidata: :environment do
    require 'sparql/client'

    endpoint = 'https://query.wikidata.org/sparql'
    client = SPARQL::Client.new(endpoint)

    Account.where.not(wikidata_id: nil).find_each do |account|
      query = <<-SPARQL
          SELECT ?description ?website ?address ?logo WHERE {
            BIND(wd:#{account.wikidata_id} AS ?item)
            OPTIONAL { ?item schema:description ?description . FILTER(LANG(?description) = "en") }
            OPTIONAL { ?item wdt:P856 ?website . }
            OPTIONAL { ?item wdt:P6375 ?address . }
            OPTIONAL { ?item wdt:P154 ?logo . }
          }
      SPARQL

      result = client.query(query).first

      next unless result

      account.update(background_info: result[:description].to_s) if account.background_info.blank? && result[:description]
      account.update(website: result[:website].to_s) if account.website.blank? && result[:website]
      # account.update(billing_address: result[:address].to_s) if account.billing_address.blank? && result[:address]
      # Assuming you have a logo field on your account model
      # account.update(logo: result[:logo].to_s) if account.logo.blank? && result[:logo]

      puts "Updated account: #{account.name}"
    rescue StandardError => e
      puts "Error updating account #{account.name}: #{e.message}"
    end
  end
end
