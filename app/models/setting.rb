class Setting < ActiveRecord::Base
  
  #-------------------------------------------------------------------
  def self.method_missing(method, *args)
    method_name = method.to_s
    super(method, *args)
 
    rescue NoMethodError
      if method_name.last == "="
        self[method_name.sub("=", "")] = args.first
      else
        self[method_name]
      end
    end

    # Get.
    #-------------------------------------------------------------------
    def self.[] (name)
      settings = self.find_by_name(name.to_s)
      settings ? Marshal.load(Base64.decode64(settings.value || settings.default_value)) : nil
    end

    # Set.
    #-------------------------------------------------------------------
    def self.[]= (name, value)
      settings = self.find_by_name(name.to_s) || self.new(:name => name.to_s)
      settings.value = Base64.encode64(Marshal.dump(value))
      settings.save
    end
    
end
