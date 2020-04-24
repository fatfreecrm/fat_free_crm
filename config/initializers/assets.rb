# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += ['print.css', 'jquery-ui/*', 'jquery_ui_datepicker/*.js']

# Don't initialize Rails environment
Rails.application.config.assets.initialize_on_precompile = false
Rails.application.config.assets.precompile += %w(1x1.gif avatar.jpg facebook.gif info_tiny.png loading.gif skype.gif stars.gif)
Rails.application.config.assets.precompile += %w(asterisk.gif blog.gif info.png linkedin.gif notifications.png sortable.gif twitter.gif)
Rails.application.config.assets.precompile += %w(application.js)
Rails.application.config.assets.precompile += %w(application.css)
