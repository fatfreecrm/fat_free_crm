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

    # Make sure we reload :uuid attribute that gets created by MySQL.
    #--------------------------------------------------------------------------
    def save(*args)
      success = super(*args)
      self.uuid = self.class.find(self.id, :select => :uuid).uuid unless self.uuid?
      success
    end

  end

end
