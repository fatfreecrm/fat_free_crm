# frozen_string_literal: true

require 'net/http'
require 'nokogiri'
require 'json'

class AccountWebsiteJob < ApplicationJob
  queue_as :default

  def perform(account)
    return if account.website.blank?

    uri = URI.parse(account.website)
    uri = URI.parse("http://#{account.website}") unless uri.scheme

    response = Net::HTTP.get_response(uri)
    return unless response.is_a?(Net::HTTPSuccess)

    doc = Nokogiri::HTML(response.body)
    json_ld_scripts = doc.css('script[type="application/ld+json"]')

    json_ld_scripts.each do |script|
      process_json_ld(account, script.content)
    end
  end

  private

  def process_json_ld(account, content)
    begin
      data = JSON.parse(content)
    rescue JSON::ParserError
      return
    end

    return unless data

    # Handle both single object and array of objects
    objects = data.is_a?(Array) ? data : [data]

    # Handle @graph
    objects += data['@graph'] if data.is_a?(Hash) && data['@graph']
    objects.compact!
    objects.uniq!

    objects.each do |obj|
      next unless obj.is_a?(Hash)

      type = obj['@type']
      update_account_from_org(account, obj) if type == 'Organization' || Array(type).include?('Organization')

      about = obj['about']
      next unless (type == 'WebPage' || Array(type).include?('WebPage')) && about

      Array(about).each do |about_obj|
        next unless about_obj.is_a?(Hash)

        about_type = about_obj['@type']
        if about_type == 'Organization' || Array(about_type).include?('Organization')
          update_account_from_org(account, about_obj)
        elsif about_obj['@id']
          # Look for the referenced object in the graph
          referenced_org = objects.find do |o|
            o.is_a?(Hash) &&
              o['@id'] == about_obj['@id'] &&
              (o['@type'] == 'Organization' || Array(o['@type']).include?('Organization'))
          end
          update_account_from_org(account, referenced_org) if referenced_org
        end
      end
    end

    WikidataJob.perform_later(account) if account.wikidata_id.present?
  end

  def update_account_from_org(account, org)
    updates = {}

    updates[:phone] = org['telephone'] if account.phone.blank? && org['telephone'].present?
    updates[:email] = org['email'] if account.email.blank? && org['email'].present?
    updates[:fax] = org['faxNumber'] if account.fax.blank? && org['faxNumber'].present?

    if org['sameAs'].present?
      Array(org['sameAs']).each do |url|
        next unless url.is_a?(String)

        case url
        when %r{facebook\.com/}
          updates[:facebook] ||= url if account.facebook.blank?
        when %r{instagram\.com/}
          updates[:instagram] ||= url if account.instagram.blank?
        when %r{(twitter\.com|x\.com)/}
          updates[:twitter] ||= url if account.twitter.blank?
        when %r{linkedin\.com/}
          updates[:linkedin] ||= url if account.linkedin.blank?
        when %r{bsky\.app/}
          updates[:bluesky] ||= url if account.bluesky.blank?
        when /mastodon/
          updates[:mastodon] ||= url if account.mastodon.blank?
        end
      end
    end

    if org['geo'].present? && org['geo']['@type'] == 'GeoCoordinates'
      updates[:latitude] = org['geo']['latitude'].to_f if account.latitude.blank? && org['geo']['latitude'].present?
      updates[:longitude] = org['geo']['longitude'].to_f if account.longitude.blank? && org['geo']['longitude'].present?
    end

    if updates.any?
      account.assign_attributes(updates)
      account.save(validate: false)
    end

    update_address(account, org['address']) if org['address'].present? && (org['address']['@type'] == 'PostalAddress' || org['address'].is_a?(Hash))
  end

  def update_address(account, addr_data)
    address = account.billing_address || account.addresses.new(address_type: 'Billing')
    return if address.persisted?

    address.street1 = addr_data['streetAddress'] if addr_data['streetAddress'].present?
    address.city = addr_data['addressLocality'] if addr_data['addressLocality'].present?
    address.state = addr_data['addressRegion'] if addr_data['addressRegion'].present?
    address.zipcode = addr_data['postalCode'] if addr_data['postalCode'].present?
    address.country = addr_data['addressCountry'] if addr_data['addressCountry'].present?

    address.save(validate: false) if address.changed?
  end
end
