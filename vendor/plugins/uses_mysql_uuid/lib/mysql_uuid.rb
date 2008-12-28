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

    # Determine whether to call regular find() or find_by_uuid().
    #--------------------------------------------------------------------------
    def find(*args)
      finder = (args.first =~ /\A[a-f\d\-]{36}\Z/ ? :fin_by_uuid : :find)
      send(finder, *args)
    end

  end

end
