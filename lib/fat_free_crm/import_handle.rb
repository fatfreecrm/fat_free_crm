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

      def get_columns(path)
        headers = Hash.new
        xlsx = Roo::Spreadsheet.open(path)
        sheet = xlsx.sheet(0)
        sheet.row(1).each_with_index { |header, i|
          headers[header] = i
        }
        headers
      end

      def process(importer)
        errors = []
        map = JSON.parse(importer.map)
        xlsx = Roo::Spreadsheet.open(importer.attachment.path)

        xlsx.each_with_pagename do |name, sheet|
          # headers = Hash.new
          # sheet.row(1).each_with_index { |header, i|
          #   headers[header] = i
          # }
          ((sheet.first_row + 1)..sheet.last_row).each do |row|
            item = importer.entity_type.constantize.new

            map.each do |att,i|
              if i
                value = sheet.row(i)
                item.instance_variable_set("@#{att}".to_sym, value)
              end
            end
            if item.valid?
              item.save
            else
              errors << @importer.errors.full_messages
            end
          end
        end

        if len(errors) == 0
          importer.status = :imported
        else
          importer.status = :error
          importer.messages = errors.to_json
        end
        importer.save

        importer
      end
    end
  end
end


