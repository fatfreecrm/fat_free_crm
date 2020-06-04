require 'ransack/context'

module Ransack
  Context.class_eval do
    def ransackable_attribute?(str, klass)
      klass.ransackable_attributes(auth_object).map(&:first).include? str
    end
  end
end