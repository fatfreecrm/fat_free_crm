# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_fat_free_crm_session' if FatFreeCRM.application?
