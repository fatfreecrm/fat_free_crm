# frozen_string_literal: true

module BundlesHelper
  # Sidebar checkbox control for filtering bundles by location.
  #----------------------------------------------------------------------------
  def bundle_location_checkbox(location, count)
    entity_filter_checkbox(:location, location, count)
  end

  # Quick bundle summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def bundle_summary(bundle)
    [
      bundle.qr_code,
      bundle.location,
      t('pluralize.sample', bundle.samples.count),
      number_to_currency(bundle.total_value, precision: 2),
      t(:added_by, time_ago: time_ago_in_words(bundle.created_at), user: bundle.user_id_full_name)
    ].compact.join(', ')
  end

  # Generates a select list with bundles
  #----------------------------------------------------------------------------
  def bundle_select(options = {})
    options[:selected] = @bundle&.id.to_i
    bundles = ([@bundle&.new_record? ? nil : @bundle] + Bundle.my(current_user).order(:name).limit(25)).compact.uniq
    collection_select :bundle, :id, bundles, :id, :name,
                      { include_blank: true },
                      style: 'width:330px;', class: 'select2',
                      placeholder: t(:select_bundle)
  end

  # Display location badge
  #----------------------------------------------------------------------------
  def bundle_location_badge(bundle)
    return content_tag(:span, t(:no_location), class: 'badge bg-secondary') if bundle.location.blank?

    content_tag(:span, bundle.location, class: 'badge bg-primary')
  end

  # Display fire sale count badge
  #----------------------------------------------------------------------------
  def bundle_fire_sale_badge(bundle)
    count = bundle.fire_sale_samples_count
    return '' if count.zero?

    content_tag(:span, "#{count} Fire Sale", class: 'badge bg-danger')
  end
end
