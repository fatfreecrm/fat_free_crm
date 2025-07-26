class Contract < ActiveRecord::Base
  belongs_to :account
  has_many :contracted_products
  has_many :products, through: :contracted_products

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail versions: { class_name: 'Version' }, ignore: [:subscribed_users]
  exportable
  sortable by: ["created_at DESC", "updated_at DESC"], default: "created_at DESC"
end
