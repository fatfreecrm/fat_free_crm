# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      entities = [Account, Campaign, Contact, Lead, Opportunity]

      can :create, :all
      can :manage, entities, :access => 'Public'
      can :manage, entities + [Task], :user_id => user.id

      entities.each do |klass|
        permissions = user.permissions.where(:asset_type => klass.name)
        can :manage, klass, :id => permissions.map(&:asset_id)
      end
    end
  end
end
