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

  def entity_attrs
    attrs = []
    case self.entity_type
    when 'campaign'
      attrs = %w(user_id assigned_to name access status budget target_leads target_conversion target_revenue leads_count opportunities_count revenue starts_on ends_on objectives deleted_at created_at  updated_at background_info)
    when 'lead'
      attrs = %w(user_id assigned_to first_name last_name access title company source status referred_by email alt_email phone mobile blog linkedin facebook twitter rating do_not_call deleted_at created_at updated_at background_info skype)
    else
      # Todo
      puts "Error: entity_type not found"
    end
    attrs
  end

  def get_messages()
    JSON.parse(messages)
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_importer, self)
end
