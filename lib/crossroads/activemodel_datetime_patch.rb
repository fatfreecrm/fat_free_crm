# https://rails.lighthouseapp.com/projects/8994/tickets/6096-to_xml-datetime-format-regression

module ActiveModel
  module Serializers
    module Xml
      class Serializer #:nodoc:
        class Attribute #:nodoc:
          def initialize(name, serializable, raw_value=nil)
            @name, @serializable = name, serializable

            raw_value = raw_value.in_time_zone if raw_value.respond_to?(:in_time_zone)

            @value = raw_value || @serializable.send(name)
            @type  = compute_type
          end
        end
      end
    end
  end
end
