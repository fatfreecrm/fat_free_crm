# Attributes
# id: nil
# user_id: nil,
# assigned_to: nil,
# access: nil,
# source: nil,
# background_info: nil,
# created_at: nil,
# updated_at: nil,
# category: nil,
# opportunity_id: nil,
# window_start_date: nil,
# window_end_date: nil,
# opened_at: nil,
# closed_at: nil,
# projected_return_date: nil,
# contact_id: nil,
# subscribed_users: #<Set: {}>,
# case_number: nil,
# tag_list: nil> 

module FatFreeCrm
  class IndexCase < ActiveRecord::Base
  	belongs_to :user
  	belongs_to :assignee, class_name: "::FatFreeCrm::User", foreign_key: :assigned_to
    belongs_to :contact, class_name: "::FatFreeCrm::Contact"

 		belongs_to :opportunity, class_name: "::FatFreeCrm::Opportunity"
 		has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'
    has_many :emails, as: :mediator
    has_many :exposures, dependent: :destroy
    has_many :investigations, dependent: :destroy

    serialize :subscribed_users, Set

  	uses_user_permissions
    acts_as_commentable
    uses_comment_extensions
    exportable
    acts_as_taggable_on :tags
    has_paper_trail versions: {class_name: "FatFreeCrm::Version"}, ignore: [:subscribed_users]

    has_ransackable_associations %w[opportunity]
    ransack_can_autocomplete

    accepts_nested_attributes_for :exposures, allow_destroy: true
    accepts_nested_attributes_for :investigations, allow_destroy: true

  	sortable by: ["name ASC", "rating DESC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"
  end
end
