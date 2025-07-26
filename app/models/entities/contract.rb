class Contract < ActiveRecord::Base
  belongs_to :account
  has_many :contracted_products
  has_many :products, through: :contracted_products

  exportable
  sortable by: ["created_at DESC", "updated_at DESC"], default: "created_at DESC"
end
