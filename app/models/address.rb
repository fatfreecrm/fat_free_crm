# == Schema Information
# Schema version: 26
#
# Table name: address
#
#  id                 :integer(4)      not null, primary key
#  street1            :string(255)
#  street2            :string(255)
#  city               :string(255)
#  state              :string(255)
#  zipcode            :string(255)
#  country            :string(2)
#  full_address       :string(255)
#  address_type       :string(255)
#  addressable_id     :integer(4)
#  addressable_type   :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  deleted_at         :datetime

class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true

  acts_as_paranoid

  named_scope :business, :conditions => "address_type='Business'"
  named_scope :billing,  :conditions => "address_type='Billing'"
  named_scope :shipping, :conditions => "address_type='Shipping'"

  # Checks if the address is blank for both single and compound addresses.
  #----------------------------------------------------------------------------
  def blank?
    if Setting.compound_address
      %w(street1 street2 city state zipcode country).all? { |attr| self.send(attr).blank? }
    else
      self.full_address.blank?
    end
  end

end