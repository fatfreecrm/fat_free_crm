# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Admin::FieldsHelper
  # Returns the list of :null and :safe database column transitions.
  # Only these options should be shown on the custom field edit form.
  def field_edit_as_options(field = nil)
    # Return every available field_type if no restriction
    options = (field.as.present? ? field.available_as : Field.field_types).keys
    options.map { |k| [t("field_types.#{k}.title"), k] }
  end

  def field_group_options
    FieldGroup.all.map { |fg| [fg.name, fg.id] }
  end
end
