# frozen_string_literal: true

namespace :ffcrm do
  desc 'Fetch account data from Wikidata'
  task wikidata: :environment do
    require 'sparql/client'

    endpoint = 'https://query.wikidata.org/sparql'
    client = SPARQL::Client.new(endpoint, headers: { 'User-Agent' => 'Fat Free CRM' })

    n = 0
    Account.where.not(wikidata_id: nil).find_each do |account|
      n += 1

      sleep(1) if (n % 10).zero? # Throttle requests to avoid hitting rate limits

      query = <<-SPARQL
          SELECT ?description ?website ?address ?logo ?twitter ?linkedin ?instagram ?mastodon ?facebook ?bluesky ?blog WHERE {
            BIND(wd:#{account.wikidata_id} AS ?item)
            OPTIONAL { ?item schema:description ?description . FILTER(LANG(?description) = "en") }
            OPTIONAL { ?item wdt:P856 ?website . }
            OPTIONAL { ?item wdt:P6375 ?address . }
            OPTIONAL { ?item wdt:P154 ?logo . }
            OPTIONAL {
              ?item p:P2002 ?twitter_statement .
              ?twitter_statement ps:P2002 ?twitter .
              FILTER NOT EXISTS { ?twitter_statement pq:P582 ?twitter_end_date }
            }
            OPTIONAL {
              ?item p:P4264 ?linkedin_statement .
              ?linkedin_statement ps:P4264 ?linkedin .
              FILTER NOT EXISTS { ?linkedin_statement pq:P582 ?linkedin_end_date }
            }
            OPTIONAL {
              ?item p:P2003 ?instagram_statement .
              ?instagram_statement ps:P2003 ?instagram .
              FILTER NOT EXISTS { ?instagram_statement pq:P582 ?instagram_end_date }
            }
            OPTIONAL {
              ?item p:P4033 ?mastodon_statement .
              ?mastodon_statement ps:P4033 ?mastodon .
              FILTER NOT EXISTS { ?mastodon_statement pq:P582 ?mastodon_end_date }
            }
            OPTIONAL {
              ?item p:P2013 ?facebook_statement .
              ?facebook_statement ps:P2013 ?facebook .
              FILTER NOT EXISTS { ?facebook_statement pq:P582 ?facebook_end_date }
            }
            OPTIONAL {
              ?item p:P12361 ?bluesky_statement .
              ?bluesky_statement ps:P12361 ?bluesky .
              FILTER NOT EXISTS { ?bluesky_statement pq:P582 ?bluesky_end_date }
            }
            OPTIONAL {
              ?item p:P1581 ?blog_statement .
              ?blog_statement ps:P1581 ?blog .
              FILTER NOT EXISTS { ?blog_statement pq:P582 ?blog_end_date }
            }
          }
      SPARQL

      result = client.query(query).first

      next unless result

      updates = {}
      updates[:background_info] = result[:description].to_s if account.background_info.blank? && result[:description]
      updates[:website] = result[:website].to_s if account.website.blank? && result[:website]

      updates[:twitter] = "https://twitter.com/#{result[:twitter]}" if account.twitter.blank? && result[:twitter]

      updates[:linkedin] = "https://www.linkedin.com/company/#{result[:linkedin]}" if account.linkedin.blank? && result[:linkedin]

      updates[:instagram] = "https://www.instagram.com/#{result[:instagram]}" if account.instagram.blank? && result[:instagram]

      if account.mastodon.blank? && result[:mastodon]
        m = result[:mastodon].to_s
        updates[:mastodon] = if m.start_with?("http")
                               m
                             elsif m =~ /^@?([^@]+)@(.+)$/
                               "https://#{Regexp.last_match(2)}/@#{Regexp.last_match(1)}"
                             else
                               m
                             end
      end

      updates[:facebook] = "https://www.facebook.com/#{result[:facebook]}" if account.facebook.blank? && result[:facebook]

      updates[:bluesky] = "https://bsky.app/profile/#{result[:bluesky]}" if account.bluesky.blank? && result[:bluesky]

      updates[:blog] = result[:blog].to_s if account.blog.blank? && result[:blog]

      account.update(updates) if updates.any?

      puts "Updated account: #{account.name}"
    rescue StandardError => e
      puts "Error updating account #{account.name}: #{e.message}"
    end
  end
end
