class AppConfig
  class << self
    @@config = nil

    protected
    def config
      @@config ||= YAML.load_file(Rails.root.join(*%w(config application.yml)))[Rails.env]
    end

    public

    def has_setting?(name)
      self.config.has_key?(name.to_s)
    end

    def method_missing(name, *args)
      if has_setting?(name.to_s)
        self.config[name.to_s]
      else
        super
      end
    end
  end
end