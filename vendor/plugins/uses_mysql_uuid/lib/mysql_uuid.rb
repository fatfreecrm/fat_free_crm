module MySQL_UUID

  #----------------------------------------------------------------------------
  def self.included(base)
    base.extend(ClassMethods)
  end

  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  module ClassMethods

    #--------------------------------------------------------------------------
    def uses_mysql_uuid
      # Don't let ActiveRecord call this twice.
      include InstanceMethods unless already_uses_mysql_uuid?
    end

    #--------------------------------------------------------------------------
    def already_uses_mysql_uuid?
      self.included_modules.include?(InstanceMethods)
    end

  end

  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  module InstanceMethods

    # Override default :id with :uuid for the model so it shows up in URLs.
    #--------------------------------------------------------------------------
    def to_param
      self.uuid
    end

    # Reload newly saved record since named routes rely on uuid being present.
    #--------------------------------------------------------------------------
    def save(*args)
      success = super(*args)
      self.reload unless self.uuid
      success
    end

  end

end
