module FatFreeCrm
  module IndexCasesHelper
    include ::FatFreeCrm::AddressesHelper
    include ::FatFreeCrm::UsersHelper
    include ::FatFreeCrm::CommentsHelper
    include ::FatFreeCrm::OpportunitiesHelper
    include ::FatFreeCrm::LeadsHelper

    # Sidebar checkbox control for filtering index_cases by category.
    #----------------------------------------------------------------------------
    def index_case_category_checkbox(category, count)
      entity_filter_checkbox(:category, category, count)
    end

    # Quick index_case summary for RSS/ATOM feeds.
    #----------------------------------------------------------------------------
    def index_case_summary(index_case)
      [number_to_currency(index_case.opportunities.pipeline.map(&:weighted_amount).sum, precision: 0),
      t(:added_by, time_ago: time_ago_in_words(index_case.created_at), user: index_case.user_id_full_name),
      t('pluralize.contact', index_case.contacts_count),
      t('pluralize.opportunity', index_case.opportunities_count),
      t('pluralize.comment', index_case.comments.count)].join(', ')
    end

    # Output index_case url for a given contact
    # - a helper so it is easy to override in plugins that allow for several index_cases
    #----------------------------------------------------------------------------
    def index_case_with_url_for(contact)
      contact.index_case ? link_to(h(contact.index_case.name), index_case_path(contact.index_case)) : ""
    end

    # Output index_case with title and department
    # - a helper so it is easy to override in plugins that allow for several index_cases
    #----------------------------------------------------------------------------
    def index_case_with_title_and_department(contact)
      text = if !contact.title.blank? && contact.index_case
              # works_at: "{{h(job_title)}} at {{h(company)}}"
              content_tag :div, t(:works_at, job_title: h(contact.title), company: h(index_case_with_url_for(contact))).html_safe
            elsif !contact.title.blank?
              content_tag :div, h(contact.title)
            elsif contact.index_case
              content_tag :div, index_case_with_url_for(contact)
            else
              ""
        end
      text += t(:department_small, h(contact.department)) unless contact.department.blank?
      text
    end
  end
end
