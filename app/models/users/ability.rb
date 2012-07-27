# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      entities = [Account, Campaign, Contact, Lead, Opportunity]

      can :create, :all
      can :manage, entities, :access => 'Public'
      can :manage, entities + [Task], :user_id => user.id
      can :manage, entities + [Task], :assigned_to => user.id
      
      #
      # Due to an obscure bug (see https://github.com/ryanb/cancan/issues/213)
      # we must switch on user.admin? here to avoid the nil constraints which
      # activate the issue referred to above.
      #
      if user.admin?
        can :manage, :all
      else
        # Group or User permissions
        t = Permission.arel_table
        scope = t[:user_id].eq(user.id)

        if (group_ids = user.group_ids).any?
          scope = scope.or(t[:group_id].eq_any(group_ids))
        end

        entities.each do |klass|
          if (asset_ids = Permission.where(scope.and(t[:asset_type].eq(klass.name))).value_of(:asset_id)).any?
            can :manage, klass, :id => asset_ids
          end
        end
      end # if user.admin?
      
    end
  end
end
