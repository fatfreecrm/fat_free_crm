class TextInput < SimpleForm::Inputs::TextInput
  def input
    add_maxlength!
    @builder.text_area(attribute_name, {:rows => 7}.merge(input_html_options))
  end
end
