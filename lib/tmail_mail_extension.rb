##
# original author: http://fernandoguillen.info
# date: 2008-08-27
#
# secondary author: Jerod Santo (http://jerodsanto.net)
# date: 2009-02-20
#
# When you have a TMail::Mail with plain text and html body parts
# there is not any easy way to extract just the html body part
#
# There is also not any easy way to extract just the plaintext body part
#
# This is a patch to try to resolve this
#
# just require 'tmail_mail_extension'
# and every TMail::Mail object will have the .body_html and .body_plain methods
#

module TMail
  class Mail

    #
    # returs an String with just the html part of the body
    # or nil if there is not any html part
    #
    def body_html
      result = nil
      if multipart?
        parts.each do |part|
          if part.multipart?
            part.parts.each do |part2|
              result = part2.unquoted_body if part2.content_type =~ /html/i
            end
          elsif !attachment?(part)
            result = part.unquoted_body if part.content_type =~ /html/i
          end
        end
      else
        result = unquoted_body if content_type =~ /html/i
      end
      result
    end
    
    #
    # returns a String with just the plaintext part of the body
    # or nil if there is not any plain part
    def body_plain
      result = nil
      if multipart?
        parts.each do |part|
          if part.multipart?
            part.parts.each do |part2|
              result = part2.unquoted_body if part2.content_type =~ /plain/i
            end
          elsif !attachment?(part)
            result = part.unquoted_body if part.content_type =~ /plain/i
          end
        end
      else
        result = unquoted_body if content_type =~ /plain/i
      end
      result
    end
    
  end
end