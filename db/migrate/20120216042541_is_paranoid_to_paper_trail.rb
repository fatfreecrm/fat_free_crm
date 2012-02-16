class IsParanoidToPaperTrail < ActiveRecord::Migration
  def up
    [Account, Campaign, Contact, Lead, Opportunity, Task].each do |klass|
      klass.where('deleted_at IS NOT NULL').each do |object|
        object.destroy          # Really destroy the object
        Activities.last.destroy # Remove the destroy activity because we should already have one indicating this object is destroyed
      end
    end
  end

  def down
  end
end
