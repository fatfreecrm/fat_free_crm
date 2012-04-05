# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    entities = [Account, Campaign, Contact, Lead, Opportunity]

    can :create, :all
    can :manage, entities, :access => 'Public'
    if user.present?
      can :manage, User if user.admin?
      can :manage, entities + [Task], :user_id => user.id
      can :manage, entities, :permissions.outer => {:user_id => user.id}
    end
  end
end
