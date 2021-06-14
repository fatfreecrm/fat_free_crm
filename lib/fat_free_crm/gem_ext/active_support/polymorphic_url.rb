# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# Fixes https://github.com/rails/rails/pull/31746
module FatFreeCRM
  module SecurePolymorphicUrl
    def polymorphic_url(record_or_hash_or_array, options = {})
      options[:secure] = true if Rails.configuration.force_ssl
      super(record_or_hash_or_array, options)
    end
  end
end

ActionDispatch::Routing::PolymorphicRoutes.send(:prepend, FatFreeCRM::SecurePolymorphicUrl)
