# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :ffcrm do
  namespace :import do
    desc "Import files..."
    task process: :environment do
      require 'roo'

      importers = Importer.all
      importers.each do |importer|
        require 'roo'

        xlsx = Roo::Spreadsheet.open(importer.attachment.path, extension: :xls)

        xlsx.each_with_pagename do |name, sheet|
          headers = Hash.new
          sheet.row(1).each_with_index {|header,i|
            headers[header] = i
          }

          ((sheet.first_row + 1)..sheet.last_row).each do |row|
            campaign = Campaign.new
            campaign.name = sheet.row(row)[headers['Name']]
            campaign.access = sheet.row(row)[headers['Access']]
            campaign.status = sheet.row(row)[headers['Status']]
            campaign.budget =sheet.row(row)[headers['Budget']]
            campaign.target_leads =sheet.row(row)[headers['target leads']]
            campaign.target_conversion =sheet.row(row)[headers['Target conversion']]
            campaign.leads_count =sheet.row(row)[headers['Number of leads']]
            campaign.opportunities_count =sheet.row(row)[headers['Total Opportunities']]
            campaign.revenue =sheet.row(row)[headers['target revenue']]
            campaign.starts_on =sheet.row(row)[headers['start date']]
            campaign.ends_on =sheet.row(row)[headers['end date']]
            campaign.objectives =sheet.row(row)[headers['Objectives']]
            campaign.background_info =sheet.row(row)[headers['Background']]
            if campaign.save
              puts 'Saved'
            else
              puts campaign.errors.full_messages
            end


          # headers.each do |header, i |
            #   value = sheet.row(row)[i]
            # end
          end

          # sheet.each_row(offset: 1) do |row| # skip first row
          #   puts row
          # end
        end


        puts
      end
    end
  end
end
