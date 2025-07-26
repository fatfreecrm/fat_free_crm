class Contract < ActiveRecord::Base
  belongs_to :account
  has_many :contracted_products
  has_many :products, through: :contracted_products
end
