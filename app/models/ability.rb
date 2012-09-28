class Ability
  include CanCan::Ability

  def initialize(user_info)

    if !user_info # guest user (not logged in)
      can :read, Survey do |survey|
        nil
      end
    else
      role = user_info[:role]
      if role == 'admin'
        can :manage, :all # TODO: Verify this
      elsif role == 'cso_admin'
        can :read, Survey, :organization_id => user_info[:org_id]
        can :create, Survey
        can :publish, Survey
        can :edit, Survey
        can :share, Survey
        can :destroy, Survey
      elsif role == 'user'
        can :read, Survey, :survey_users => { :user_id => user_info[:user_id ] }
        cannot :destroy, Survey
      end
    end
  end
end
