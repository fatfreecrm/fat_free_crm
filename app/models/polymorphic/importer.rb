# == Schema Information
#
# Table name: importers
#
#  id                       :integer         not null, primary key
#  entity_type              :string
#  entity_id                :integer
#  attachment_file_size    :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  status                  :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#
require 'json'
class Importer < ActiveRecord::Base
  attribute :entity_attrs

  has_attached_file :attachment, :path => ":rails_root/public/importers/:id/:filename"

  validates_attachment :attachment, presence: true

  validates_attachment_content_type :attachment,
                                    :content_type => %w(text/xml application/xml application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/x-ole-storage),
                                    :message => 'Only EXCEL files are allowed.'
  validates_attachment_file_name :attachment, matches: [/\.xls/, /\.xlsx?$/]

  def get_messages()
    JSON.parse(messages)
  end

  def entity_class
    self.entity_type.capitalize.constantize
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_importer, self)
end
