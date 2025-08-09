# frozen_string_literal: true

class IsParanoidToPaperTrail < ActiveRecord::Migration[4.2]
  def up
    [Account, Campaign, Contact, Lead, Opportunity, Task].each do |klass|
      klass.where('deleted_at IS NOT NULL').each(&:destroy)
    end
  end

  def down
  end
end
