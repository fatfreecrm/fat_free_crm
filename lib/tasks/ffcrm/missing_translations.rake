# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

require 'missing_translation_detector'

namespace :ffcrm do
  namespace :missing_translations do
    desc 'Detects missing translations for a locale - Takes a locale and compares with "en-US".'
    task :detect, [:locale] => [:environment] do |_t, args|
      base_locale = 'en-US'

      [[base_locale, args[:locale]],
       ["#{base_locale}_fat_free_crm", "#{args[:locale]}_fat_free_crm"],
       ["#{base_locale}_ransack", "#{args[:locale]}_ransack"]].each do |locale_file_names|
        detector = MissingTranslationDetector.new locale_file_names.first,
                                                  locale_file_names.last
        detector.detect

        next unless detector.missing_translations?

        puts
        puts "Detected missing translations within \"config/locales/#{locale_file_names.last}.yml\":"
        puts

        detector.missing_translations.each do |missing|
          puts "#{missing.key_path.join(' => ')}: #{missing.value}"
        end
      end
    end
  end
end
