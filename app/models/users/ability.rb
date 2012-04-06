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
        can :manage, klass, :id => Permission.where('asset_type = ? AND (user_id = ? OR group_id = ?)', klass.name, user.id, user.group_ids).map(&:asset_id)
      end
    end
  end
end
