# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
# See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    # handle signup
    can(:create, User) if User.can_signup?

    if user.present?
      entities = [Account, Campaign, Contact, Lead, Opportunity]

      # User
      can :manage, User, id: user.id # can do any action on themselves

      # Tasks
      can :create, Task
      can :manage, Task, user: user.id
      can :manage, Task, assigned_to: user.id
      can :manage, Task, completed_by: user.id

      # Entities
      can :manage, entities, access: 'Public'
      can :manage, entities + [Task], user_id: user.id
      can :manage, entities + [Task], assigned_to: user.id

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

        permissions = Permission.select(:asset_type, :asset_id).where(scope).where(asset_type: entities.map { |k| k.name.to_s })
        permissions.each do |p|
          can :manage, p.asset_type.constantize, id: p.asset_id
        end
      end

    end
  end

  ActiveSupport.run_load_hooks(:fat_free_crm_ability, self)
end
