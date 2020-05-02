# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20120216042541)

class IsParanoidToPaperTrail < ActiveRecord::Migration[4.2]
  def up
    [FatFreeCrm::Account, FatFreeCrm::Campaign, FatFreeCrm::Contact, FatFreeCrm::Lead, FatFreeCrm::Opportunity, FatFreeCrm::Task].each do |klass|
      klass.where('deleted_at IS NOT NULL').each(&:destroy)
    end
  end

  def down
  end
end
