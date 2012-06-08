# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module CrmTagsHelper

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

  # Return asset tags to be built manually if the asset failed validation.
  def unsaved_param_tags(asset)
    params[asset][:tag_list].join.split(",").map {|x|
      Tag.find_by_name(x.strip)
    }.compact.uniq
  end
end

