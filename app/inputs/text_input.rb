# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class TextInput < SimpleForm::Inputs::TextInput
  def input(wrapper_options)
    @builder.text_area(attribute_name, { rows: 7 }.merge(merge_wrapper_options(input_html_options, wrapper_options)))
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_text_input, self)
end
