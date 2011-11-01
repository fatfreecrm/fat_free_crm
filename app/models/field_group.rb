class FieldGroup < ActiveRecord::Base

  def klass
    klass_name.constantize
  end

  def table_name
    klass.table_name
  end

end
