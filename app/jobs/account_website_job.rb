require 'net/http'
require 'nokogiri'
require 'json'

class AccountWebsiteJob < ApplicationJob
  queue_as :default

  def perform(account)
    return unless account.website.present?

    uri = URI.parse(account.website)
    uri = URI.parse("http://#{account.website}") unless uri.scheme

    response = Net::HTTP.get_response(uri)
    return unless response.is_a?(Net::HTTPSuccess)

    doc = Nokogiri::HTML(response.body)
    json_ld_scripts = doc.css('script[type="application/ld+json"]')

    json_ld_scripts.each do |script|
      begin
        data = JSON.parse(script.content)
      rescue JSON::ParserError
        next
      end

      next unless data

      # Handle both single object and array of objects
      objects = data.is_a?(Array) ? data : [data]

      # Handle @graph
      if data.is_a?(Hash) && data['@graph']
        objects += data['@graph']
      end

      objects.each do |obj|
        if obj['@type'] == 'Organization'
          update_account_from_org(account, obj)
        end
      end
    end
  end

  private

  def update_account_from_org(account, org)
    updates = {}

    updates[:phone] = org['telephone'] if account.phone.blank? && org['telephone'].present?
    updates[:email] = org['email'] if account.email.blank? && org['email'].present?
    updates[:fax] = org['faxNumber'] if account.fax.blank? && org['faxNumber'].present?

    if org['geo'].present? && org['geo']['@type'] == 'GeoCoordinates'
      updates[:latitude] = org['geo']['latitude'].to_f if account.latitude.blank? && org['geo']['latitude'].present?
      updates[:longitude] = org['geo']['longitude'].to_f if account.longitude.blank? && org['geo']['longitude'].present?
    end

    if updates.any?
      account.assign_attributes(updates)
      account.save(validate: false)
    end

    if org['address'].present? && (org['address']['@type'] == 'PostalAddress' || org['address'].is_a?(Hash))
      update_address(account, org['address'])
    end
  end

  def update_address(account, addr_data)
    address = account.billing_address || account.addresses.new(address_type: 'Billing')
    return unless address.blank?

    address.street1 = addr_data['streetAddress'] if addr_data['streetAddress'].present?
    address.city = addr_data['addressLocality'] if addr_data['addressLocality'].present?
    address.state = addr_data['addressRegion'] if addr_data['addressRegion'].present?
    address.zipcode = addr_data['postalCode'] if addr_data['postalCode'].present?
    address.country = addr_data['addressCountry'] if addr_data['addressCountry'].present?

    address.save(validate: false) if address.changed?
  end
end
