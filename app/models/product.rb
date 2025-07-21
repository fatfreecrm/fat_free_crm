class Product < ApplicationRecord
  validates :name, presence: true
  has_many :contracted_products
  has_many :contracts, through: :contracted_products
end
