class Ability
  include CanCan::Ability

  def initialize(user)
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    can :create, :all
    can [:read, :update, :destroy], :all, :access => 'Public'
    if user.present?
      can [:read, :update, :destroy], :all, :user_id => user.id
      can [:read, :update, :destroy], :all, :permissions => {:user_id => user.id}
    end
  end
end
