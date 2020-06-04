module RansackUI
  module ViewHelpers
    def ransack_ui_search(options = {})
      render 'ransack_ui/search', :options => options
    end

    def link_to_add_fields(name, f, type, options)
      new_object = f.object.send "build_#{type}"
      fields = f.send("#{type}_fields", new_object, :child_index => "new_#{type}") do |builder|
        render "ransack_ui/#{type.to_s}_fields", :f => builder, :options => options
      end

      if options[:theme].to_s == 'bootstrap'
        link_to nil, :class => "add_fields btn btn-small btn-primary", "data-field-type" => type, "data-content" => "#{fields}" do
          "<i class=\"icon-plus icon-white\"></i><span>#{name}</span>".html_safe
        end
      else
        link_to name, nil, :class => "add_fields", "data-field-type" => type, "data-content" => "#{fields}"
      end
    end

    def link_to_remove_fields(name, f, options)
      if options[:theme].to_s == 'bootstrap'
        link_to '<i class="icon-remove icon-white"></i>'.html_safe, nil, :class => "remove_fields btn btn-mini btn-danger"
      else
        link_to image_tag('ransack_ui/delete.png', :size => '16x16', :alt => name), nil, :class => "remove_fields"
      end
    end
  end
end
