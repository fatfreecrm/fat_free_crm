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

module FatFreeCRM
  module I18n

    #----------------------------------------------------------------------------
    def t(*args)
      if args.size == 1
        super(args.first, :default => args.first.to_s)
      elsif args.second.is_a?(Hash)
        super(*args)
      elsif args.second.is_a?(Fixnum)
        super(args.first, :count => args.second)
      else
        super(args.first, :value => args.second)
      end
    end

    # Scan config/locales directory for Fat Free CRM localization files
    # (i.e. *_fat_free_crm.yml) and return locale part of the file name.
    #----------------------------------------------------------------------------
    def locales
      @@locales ||= Dir.entries("#{Rails.root}/config/locales").grep(/_fat_free_crm\.yml$/) { |f| f.sub("_fat_free_crm.yml", "") }
    end

    # Return a hash where the key is locale name, and the value is language name
    # as defined in the locale_fat_free_crm.yml file.
    #----------------------------------------------------------------------------
    def languages
      @@languages ||= Hash[ locales.map{ |locale| [ locale, t(:language, :locale => locale) ] } ]
    end
  end
end

ActionView::Base.send(:include, FatFreeCRM::I18n)
ActionController::Base.send(:include, FatFreeCRM::I18n)
