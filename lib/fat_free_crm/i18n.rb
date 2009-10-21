module FatFreeCRM
  module I18n

    #----------------------------------------------------------------------------
    def t(*args)
      if args.size == 1 || args.second.is_a?(Hash)
        super(*args)
      elsif args.second.is_a?(Fixnum)
        super(args.first, :count => args.second)
      else
        super(args.first, :value => args.second)
      end
    end

    # Scans config/locales directory for Fat Free CRM localization files
    # (i.e. *_fat_free_crm.yml) and returns locale part of the file name.
    #----------------------------------------------------------------------------
    def locales
      @@locales ||= Dir.glob(File.join(RAILS_ROOT, "config", "locales", "*.yml")).map do |f|
        File.basename(f).split('.').first =~ /(.+?)_fat_free_crm$/ ? $1 : nil
      end.compact
    end

    # Returns a hash where the key is locale name, and the value is language name
    # as defined in the locale_fat_free_crm.yml file.
    #----------------------------------------------------------------------------
    def languages
      @@languages ||= locales.inject({}) do |hash, locale|
        $stderr.puts "#{locale}.fat_free_crm"
        puts "#{locale}.fat_free_crm"
        hash[locale] = t(:language, :locale => locale)
        hash
      end
    end

  end
end
