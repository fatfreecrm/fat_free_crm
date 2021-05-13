# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class CustomFieldDatePair < CustomFieldPair
  # For rendering paired values
  # Handle case where both pairs are blank
  #------------------------------------------------------------------------------
  def render_value(object)
    return "" unless paired_with.present?

    from = render(object.send(name))
    to = render(object.send(paired_with.name))
    if from.present? && to.present?
      I18n.t('pair.from_to', from: from, to: to)
    elsif from.present? && !to.present?
      I18n.t('pair.from_only', from: from)
    elsif !from.present? && to.present?
      I18n.t('pair.to_only', to: to)
    else
      ""
    end
  end

  def render(value)
    value&.strftime(I18n.t("date.formats.mmddyy"))
  end

  def custom_validator(obj)
    super
    # validate when we get to 2nd of the pair
    if pair_id.present?
      start = CustomFieldPair.find(pair_id)
      return if start.nil?

      from = obj.send(start.name)
      to = obj.send(name)
      obj.errors.add(name.to_sym, ::I18n.t('activerecord.errors.models.custom_field.endbeforestart', field: start.label)) if from.present? && to.present? && (from > to)
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_date_pair, self)
end
