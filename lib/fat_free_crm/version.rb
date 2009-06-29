module FatFreeCRM
  class Version
    MAJOR = 0
    MINOR = 9
    TINY  = 3

    def self.to_a
      [ MAJOR, MINOR, TINY ]
    end
    
    def self.to_s
      self.to_a.join(".")
    end
  end
end