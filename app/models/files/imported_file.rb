# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: imported_files
#
#  id              :integer         not null, primary key
#  filename        :string(64)      default(""), not null
#  md5sum          :string(32)      default(""), not null
#

class ImportedFile < ActiveRecord::Base
  before_validation :generate_md5sum

  validate  :filetype

  validates :filename, presence: true
  validates :md5sum, presence: true
  validates :md5sum, uniqueness: { message: "file already imported" }

  def generate_md5sum
    self.md5sum = Digest::MD5.hexdigest File.open(filename).read unless filename.empty? rescue ""
  end

  private

  def filetype
    valid = File.open(filename).type_from_file_command == "application/vnd.ms-excel" rescue ""
    if valid == ""
      errors.add(:filename, "no such file")
    end
    unless valid
      errors.add(:filename, "invalid filetype")
    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_imported_file, self)
end
