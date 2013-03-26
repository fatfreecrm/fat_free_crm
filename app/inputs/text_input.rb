# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class TextInput < SimpleForm::Inputs::TextInput
  def input
    @builder.text_area(attribute_name, {:rows => 7}.merge(input_html_options))
  end
end
