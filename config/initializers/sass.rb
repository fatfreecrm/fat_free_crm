# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'sass/plugin'

Sass::Plugin.options.merge!(
  :template_location => 'app/stylesheets/media',
  :css_location => ENV['HEROKU'] ? 'tmp/stylesheets' : 'public/stylesheets'
)

#~ Rails.configuration.middleware.delete('Sass::Plugin::Rack')
#~ Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Sass::Plugin::Rack')

#~ Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
    #~ :urls => ['/stylesheets'],
    #~ :root => "#{Rails.root}/tmp")
