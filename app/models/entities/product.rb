class Product < ActiveRecord::Base
  validates :name, presence: true
  has_many :contracted_products
  has_many :contracts, through: :contracted_products

  exportable
  sortable by: ["name ASC", "created_at DESC", "updated_at DESC"], default: "created_at DESC"
  # :name, :sku, :description, :image_url, :url, :gtin, :brand
end
