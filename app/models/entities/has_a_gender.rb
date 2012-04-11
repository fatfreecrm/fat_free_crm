# Include this module in models, which have a "gender" database column.
module HasAGender
  extend ActiveSupport::Concern
  GENDER = %w{m f}
  
  included do
    validates :gender, :inclusion => { :in => GENDER }
  end
  
  module ClassMethods
    # Returns an array, which acts as a mapping between gender key and human readable name.
    #----------------------------------------------------------------------------
    def dropdown_list
      GENDER.map { |gender| [humanize_gender_for(gender), gender] }
    end
    
    # Returns the human readable name for a given gender key.
    # Returns null if the given gender is unknown.
    #----------------------------------------------------------------------------
    def humanize_gender_for(key)
      case key
        when 'm'
          I18n.t 'male'
        when 'f'
          I18n.t 'female'
        else
          nil
      end
    end
  end
  
  # Returns a human readable representation of the keys "m" or "f".
  #----------------------------------------------------------------------------
  def humanize_gender
    self.class.humanize_gender_for gender
  end
end
