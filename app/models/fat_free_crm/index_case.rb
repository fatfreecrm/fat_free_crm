module FatFreeCrm
  class IndexCase < ActiveRecord::Base
  	belongs_to :user
  	belongs_to :assignee, class_name: "::FatFreeCrm::User", foreign_key: :assigned_to

 		belongs_to :opportunity, class_name: "::FatFreeCrm::Opportunity"
 		has_many :tasks, as: :asset, dependent: :destroy # , :order => 'created_at DESC'

  	uses_user_permissions
    acts_as_commentable
    uses_comment_extensions
    exportable
    acts_as_taggable_on :tags
    has_paper_trail versions: {class_name: "FatFreeCrm::Version"}, ignore: [:subscribed_users]

    has_ransackable_associations %w[opportunity]
    ransack_can_autocomplete

  	sortable by: ["name ASC", "rating DESC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"

  end
end