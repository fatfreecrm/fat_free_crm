class IsParanoidToPaperTrail < ActiveRecord::Migration
  def up
    [Account, Campaign, Contact, Lead, Opportunity, Task].each do |klass|
      klass.where('deleted_at IS NOT NULL').each do |object|
        object.destroy
      end
    end
  end

  def down
  end
end
