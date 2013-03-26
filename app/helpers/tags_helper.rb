# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module TagsHelper

  # Generate tag links for use on asset index pages.
  #----------------------------------------------------------------------------
  def tags_for_index(model)
    model.tag_list.inject([]) do |arr, tag|
      query = controller.send(:current_query) || ""
      hashtag = "##{tag}"
      if query.empty?
        query = hashtag
      elsif !query.include?(hashtag)
        query += " #{hashtag}"
      end
      arr << link_to_function(tag, "crm.search_tagged('#{query}', '#{model.class.to_s.tableize}')", :title => tag)
    end.join(" ").html_safe
  end

  def tags_for_dashboard(model)
    content_tag(:ul) do
      model.tag_list.each do |tag|
        concat(content_tag(:li, tag))
      end
    end.html_safe
  end

  # Generate tag links for the asset landing page (shown on a sidebar).
  #----------------------------------------------------------------------------
  def tags_for_show(model)
    model.tag_list.inject([]) do |arr, tag|
      arr << link_to(tag, url_for(:action => "tagged", :id => tag), :title => tag)
    end.join(" ").html_safe
  end

end
