# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# == Schema Information
#
# Table name: emails
#
#  id              :integer         not null, primary key
#  imap_message_id :string(255)     not null
#  user_id         :integer
#  mediator_id     :integer
#  mediator_type   :string(255)
#  sent_from       :string(255)     not null
#  sent_to         :string(255)     not null
#  cc              :string(255)
#  bcc             :string(255)
#  subject         :string(255)
#  body            :text
#  header          :text
#  sent_at         :datetime
#  received_at     :datetime
#  deleted_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  state           :string(16)      default("Expanded"), not null
#

class Email < ActiveRecord::Base
  belongs_to :mediator, polymorphic: true
  belongs_to :user

  has_paper_trail class_name: 'Version', meta: { related: :mediator },
                  ignore: [:state]

  def expanded?
    state == "Expanded"
  end

  def collapsed?
    state == "Collapsed"
  end

  def body
    super
  end

  def body_with_textile
    if defined?(RedCloth)
      RedCloth.new(body_without_textile).to_html
    else
      body_without_textile.to_s.gsub("\n", "<br/>")
    end
  end
  alias_method_chain :body, :textile

  ActiveSupport.run_load_hooks(:fat_free_crm_email, self)
end
