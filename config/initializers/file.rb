# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
File.class_eval do
  def type_from_file_command
    type = (begin
              original_filename.match(/\.(\w+)$/)[1]
            rescue StandardError
              "octet-stream"
            end).downcase
    mime_type = begin
                  `file -b --mime-type #{path}`.split(':').last.strip
                rescue StandardError
                  "application/x-#{type}"
                end
    mime_type = "application/x-#{type}" if mime_type.match(/\(.*?\)/)
    mime_type
  end
end
