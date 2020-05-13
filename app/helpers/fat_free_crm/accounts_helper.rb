# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module FatFreeCrm
  module AccountsHelper
    include ::FatFreeCrm::JavascriptHelper
    include ::FatFreeCrm::AddressesHelper
    include ::FatFreeCrm::UsersHelper
    include ::FatFreeCrm::CommentsHelper
    include ::FatFreeCrm::OpportunitiesHelper
    include ::FatFreeCrm::LeadsHelper

    # Sidebar checkbox control for filtering accounts by category.
    #----------------------------------------------------------------------------
    def account_category_checkbox(category, count)
      entity_filter_checkbox(:category, category, count)
    end

    # Quick account summary for RSS/ATOM feeds.
    #----------------------------------------------------------------------------
    def account_summary(account)
      [number_to_currency(account.opportunities.pipeline.map(&:weighted_amount).sum, precision: 0),
      t(:added_by, time_ago: time_ago_in_words(account.created_at), user: account.user_id_full_name),
      t('pluralize.contact', account.contacts_count),
      t('pluralize.opportunity', account.opportunities_count),
      t('pluralize.comment', account.comments.count)].join(', ')
    end

    # Output account url for a given contact
    # - a helper so it is easy to override in plugins that allow for several accounts
    #----------------------------------------------------------------------------
    def account_with_url_for(contact)
      contact.account ? link_to(h(contact.account.name), account_path(contact.account)) : ""
    end

    # Output account with title and department
    # - a helper so it is easy to override in plugins that allow for several accounts
    #----------------------------------------------------------------------------
    def account_with_title_and_department(contact)
      text = if !contact.title.blank? && contact.account
              # works_at: "{{h(job_title)}} at {{h(company)}}"
              content_tag :div, t(:works_at, job_title: h(contact.title), company: h(account_with_url_for(contact))).html_safe
            elsif !contact.title.blank?
              content_tag :div, h(contact.title)
            elsif contact.account
              content_tag :div, account_with_url_for(contact)
            else
              ""
        end
      text += t(:department_small, h(contact.department)) unless contact.department.blank?
      text
    end
  end
end
