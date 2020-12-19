# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'roo'

module FatFreeCRM
  class ImportHandle
    class << self
      def process(importer)
        result = {
            items: [],
            errors: []
        }
        xlsx = Roo::Spreadsheet.open(importer.attachment.path)

        xlsx.each_with_pagename do |name, sheet|
          headers = Hash.new
          sheet.row(1).each_with_index { |header, i|
            headers[header] = i
          }
          ((sheet.first_row + 1)..sheet.last_row).each do |row|
            campaign = Campaign.import_from_xls(sheet.row(row), headers)
            result[:items].push(campaign)
            if campaign.errors.count
              result[:errors].push(campaign.errors.full_messages)
            end
          end
        end

        result
      end
    end
  end
end


