# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

module LeadsHelper
  RATING_STARS = 5

  #----------------------------------------------------------------------------
  def stars_for(lead)
    if lead.rating == RATING_STARS
      "&#9733;".html_safe * RATING_STARS
    elsif lead.rating.nil? || lead.rating == 0
      %(<font color="gainsboro">#{"&#9733;" * RATING_STARS}</font>).html_safe
    else
      "&#9733;".html_safe * lead.rating + %(<font color="gainsboro">#{"&#9733;" * (RATING_STARS - lead.rating)}</font>).html_safe
    end
  end

  #----------------------------------------------------------------------------
  def link_to_convert(lead)
    link_to(t(:convert), convert_lead_path(lead),
      :method => :get,
      :with   => "{ previous: crm.find_form('edit_lead') }",
      :remote => true
    )
  end

  #----------------------------------------------------------------------------
  def link_to_reject(lead)
    link_to(t(:reject) + "!", reject_lead_path(lead), :method => :put, :remote => true)
  end

  #----------------------------------------------------------------------------
  def confirm_reject(lead)
    question = %(<span class="warn">#{t(:reject_lead_confirm)}</span>).html_safe
    yes = link_to(t(:yes_button), reject_lead_path(lead), :method => :put)
    no = link_to_function(t(:no_button), "$('menu').update($('confirm').innerHTML)")
    update_page do |page|
      page << "$('confirm').update($('menu').innerHTML)"
      page[:menu].replace_html "#{question} #{yes} : #{no}"
    end
  end

  # Sidebar checkbox control for filtering leads by status.
  #----------------------------------------------------------------------------
  def lead_status_checbox(status, count)
    checked = (session[:filter_by_lead_status] ? session[:filter_by_lead_status].split(",").include?(status.to_s) : count.to_i > 0)
    onclick = remote_function(
      :url      => { :action => :filter },
      :with     => h(%Q/"status=" + $$("input[name='status[]']").findAll(function (el) { return el.checked }).pluck("value")/),
      :loading  => "$('loading').show()",
      :complete => "$('loading').hide()"
    )
    check_box_tag("status[]", status, checked, :id => status, :onclick => onclick)
  end

  # Returns default permissions intro for leads
  #----------------------------------------------------------------------------
  def get_lead_default_permissions_intro(access)
    case access
      when "Private" then t(:lead_permissions_intro_private, t(:opportunity_small))
      when "Public" then t(:lead_permissions_intro_public, t(:opportunity_small))
      when "Shared" then t(:lead_permissions_intro_shared, t(:opportunity_small))
    end
  end

  # Returns default permissions intro for leads.
  #----------------------------------------------------------------------------
  def get_lead_default_permissions_intro(access)
    case access
      when "Private" then t(:lead_permissions_intro_private, t(:opportunity_small))
      when "Public"  then t(:lead_permissions_intro_public,  t(:opportunity_small))
      when "Shared"  then t(:lead_permissions_intro_shared,  t(:opportunity_small))
    end
  end

  # Do not offer :converted status choice if we are creating a new lead or
  # editing existing lead that hasn't been converted before.
  #----------------------------------------------------------------------------
  def lead_status_codes_for(lead)
    if lead.status != "converted" && (lead.new_record? || lead.contact.nil?)
      Setting.unroll(:lead_status).delete_if { |status| status.last == :converted }
    else
      Setting.unroll(:lead_status)
    end
  end

  # Lead summary for RSS/ATOM feed.
  #----------------------------------------------------------------------------
  def lead_summary(lead)
    summary = []
    summary << (lead.status ? t(lead.status) : t(:other))

    if lead.company? && lead.title?
      summary << t(:works_at, :job_title => lead.title, :company => lead.company)
    else
      summary << lead.company if lead.company?
      summary << lead.title if lead.title?
    end
    summary << "#{t(:referred_by_small)} #{lead.referred_by}" if lead.referred_by?
    summary << lead.email if lead.email.present?
    summary << "#{t(:phone_small)}: #{lead.phone}" if lead.phone.present?
    summary << "#{t(:mobile_small)}: #{lead.mobile}" if lead.mobile.present?
    summary.join(', ')
  end
end
