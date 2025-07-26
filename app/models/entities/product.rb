class Product < ActiveRecord::Base
  validates :name, presence: true
  has_many :contracted_products
  has_many :contracts, through: :contracted_products
  belongs_to :user, optional: true # TODO: Is this really optional?
  belongs_to :assignee, class_name: "User", foreign_key: :assigned_to, optional: true

  uses_user_permissions
  acts_as_commentable
  uses_comment_extensions
  acts_as_taggable_on :tags
  has_paper_trail versions: { class_name: 'Version' }, ignore: [:subscribed_users]
  exportable
  has_fields
  sortable by: ["name ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"
  serialize :subscribed_users, Array
  # :name, :sku, :description, :image_url, :url, :gtin, :brand

end
