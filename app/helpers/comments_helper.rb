# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module CommentsHelper
  def notification_emails_configured?
    config = Setting.email_comment_replies || {}
    config[:server].present? && config[:user].present? && config[:password].present?
  end

  def sanitize_comment(text)
    fragment = Loofah.fragment(text)
    # Allow only a limited set of tags and attributes
    fragment.scrub!(Loofah::Scrubber.new do |node|
      if %w[strong em p u a].include?(node.name)
        node.attributes.each_key do |name|
          node.remove_attribute(name) unless name == 'href'
        end
      else
        node.remove
      end
    end)

    # Add target and rel to links
    fragment.xpath('.//a').each do |link|
      link['rel'] = 'noopener'
      link['target'] = '_blank'
    end

    fragment.to_s.html_safe
  end
end
