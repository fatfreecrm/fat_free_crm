module ContactMods
  #see lib/esCRM.rb
  #this extends "Contact" model
  def self.included(base)
    base.class_eval do
      has_and_belongs_to_many :contact_groups
    end
  end
end
