# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# Copied from prototype-rails which is no longer maintained

module JavascriptHelper
  #   link_to_function("Show me more", nil, :id => "more_link") do |page|
  #     page[:details].visual_effect  :toggle_blind
  #     page[:more_link].replace_html "Show me less"
  #   end
  #     Produces:
  #       <a href="#" id="more_link" onclick="try {
  #         $(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);
  #         $(&quot;more_link&quot;).update(&quot;Show me less&quot;);
  #       }
  #       catch (e) {
  #         alert('RJS error:\n\n' + e.toString());
  #         alert('$(\&quot;details\&quot;).visualEffect(\&quot;toggle_blind\&quot;);
  #         \n$(\&quot;more_link\&quot;).update(\&quot;Show me less\&quot;);');
  #         throw e
  #       };
  #       return false;">Show me more</a>
  #
  def link_to_function(name, *args, &block)
    html_options = args.extract_options!.symbolize_keys

    function = block_given? ? update_page(&block) : args[0] || ''
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    content_tag(:a, name, html_options.merge(href: href, onclick: onclick))
  end
end
