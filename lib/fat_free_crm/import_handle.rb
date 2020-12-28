# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'roo'
require 'json'

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

      def get_values(map, sheet, row)
        values = {}
        map.each do |att, i|
          if i.is_a?(Hash)
            values[att] = get_values(i, sheet, row)
          elsif not i.empty? and i.to_i >= 0
            value = sheet.row(row)[i.to_i]
            values[att] = value
          end
        end

        values
      end

      def process(importer)
        errors = []
        map = JSON.parse(importer.map)
        xlsx = Roo::Spreadsheet.open(importer.attachment.path)

        xlsx.each_with_pagename do |name, sheet|
          ((sheet.first_row + 1)..sheet.last_row).each do |row|
            values = get_values(map, sheet, row)

            # TODO Do this more geneic
            business_address_attributes = {}
            if importer.entity_type == 'lead'
              values[:campaign_id] = importer.entity_id
              if values.key?('business_address_attributes')
                business_address_attributes = values.delete('business_address_attributes')
              end
            end

            item = importer.entity_type.capitalize.constantize.create(values)
            if item.valid?
              item.save
              if importer.entity_type == 'lead'
                business_address_attributes["address_type"] = "Business"
                business_address_attributes["addressable_type"] = "Lead"
                business_address_attributes["addressable_id"] = item.id
                address = Address.create(business_address_attributes)
                address.save
              end
            else
              errors << item.errors.full_messages
            end
          end
        end

        if errors.length == 0
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


