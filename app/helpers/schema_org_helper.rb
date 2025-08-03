# frozen_string_literal: true

module SchemaOrgHelper
  # Generates JSON-LD for a given object.
  #
  # @param object [ActiveRecord::Base] the object to generate JSON-LD for.
  # @return [String] the JSON-LD script tag.
  def json_ld_for(object)
    case object.class.name
    when "Contact", "Lead"
      person_schema(object)
    when "Account"
      organization_schema(object)
    end
  end

  private

  # Generates the Person schema for a Contact or Lead.
  #
  # @param person [Contact, Lead] the person to generate the schema for.
  # @return [String] the JSON-LD script tag.
  def person_schema(person)
    schema = {
      "@context": "http://schema.org",
      "@type": "Person",
      "name": person.full_name,
      "jobTitle": person.title,
      "email": [person.email, person.alt_email].compact.uniq,
      "telephone": [person.phone, person.mobile].compact.uniq,
      "faxNumber": person.fax,
      "url": person.blog,
      "sameAs": [
        person.linkedin,
        person.facebook,
        person.twitter,
        ("skype:#{person.skype}" if person.skype.present?)
      ].compact.uniq,
      "description": person.background_info
    }

    if person.try(:business_address).present?
      schema[:address] = {
        "@type": "PostalAddress",
        "streetAddress": [person.business_address.street1, person.business_address.street2].compact.join(" "),
        "addressLocality": person.business_address.city,
        "addressRegion": person.business_address.state,
        "postalCode": person.business_address.zipcode,
        "addressCountry": person.business_address.country
      }
    end

    content_tag(:script, schema.to_json.html_safe, type: "application/ld+json")
  end

  # Generates the Organization schema for an Account.
  #
  # @param organization [Account] the organization to generate the schema for.
  # @return [String] the JSON-LD script tag.
  def organization_schema(organization)
    schema = {
      "@context": "http://schema.org",
      "@type": "Organization",
      "name": organization.name,
      "url": organization.website,
      "email": organization.email,
      "telephone": [organization.phone, organization.toll_free_phone].compact.uniq,
      "faxNumber": organization.fax,
      "description": organization.background_info
    }

    if organization.billing_address.present?
      schema[:address] = {
        "@type": "PostalAddress",
        "streetAddress": [organization.billing_address.street1, organization.billing_address.street2].compact.join(" "),
        "addressLocality": organization.billing_address.city,
        "addressRegion": organization.billing_address.state,
        "postalCode": organization.billing_address.zipcode,
        "addressCountry": organization.billing_address.country
      }
    end

    content_tag(:script, schema.to_json.html_safe, type: "application/ld+json")
  end
end
