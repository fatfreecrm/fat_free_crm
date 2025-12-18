# frozen_string_literal: true

module SamplesHelper
  # Sidebar checkbox control for filtering samples by status.
  #----------------------------------------------------------------------------
  def sample_status_checkbox(status, count)
    entity_filter_checkbox(:status, status, count)
  end

  # Quick sample summary for RSS/ATOM feeds.
  #----------------------------------------------------------------------------
  def sample_summary(sample)
    [
      sample.brand,
      sample.location,
      number_to_currency(sample.best_price, precision: 2),
      sample.has_fire_sale ? 'Fire Sale' : nil,
      t(:added_by, time_ago: time_ago_in_words(sample.created_at), user: sample.user_id_full_name)
    ].compact.join(', ')
  end

  # Generates a select list with samples for a bundle
  #----------------------------------------------------------------------------
  def sample_select(options = {})
    options[:selected] = @sample&.id.to_i
    samples = ([@sample&.new_record? ? nil : @sample] + Sample.my(current_user).available.order(:name).limit(25)).compact.uniq
    collection_select :sample, :id, samples, :id, :full_name,
                      { include_blank: true },
                      style: 'width:330px;', class: 'select2',
                      placeholder: t(:select_a_sample)
  end

  # Display status badge with appropriate color
  #----------------------------------------------------------------------------
  def sample_status_badge(sample)
    status = sample.status || 'available'
    badge_class = case status
                  when 'available' then 'bg-success'
                  when 'checked_out' then 'bg-warning'
                  when 'reserved' then 'bg-info'
                  when 'discontinued' then 'bg-secondary'
                  else 'bg-secondary'
    end
    content_tag(:span, t(status), class: "badge #{badge_class}")
  end

  # Display fire sale badge if applicable
  #----------------------------------------------------------------------------
  def fire_sale_badge(sample)
    return '' unless sample.has_fire_sale

    content_tag(:span, 'FIRE SALE', class: 'badge bg-danger')
  end

  # Display discount percentage
  #----------------------------------------------------------------------------
  def discount_badge(sample)
    return '' unless sample.discount_percentage

    content_tag(:span, "#{sample.discount_percentage}% OFF", class: 'badge bg-success')
  end
end
