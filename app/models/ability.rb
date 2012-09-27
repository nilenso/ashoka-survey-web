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
        can :read, Survey, ["organization_id = ?", user_info[:org_id]] do |survey|
          survey.organization_id == user_info[:org_id]
        end
      elsif role == 'user'
        can :read, Survey, ["organization_id = ?", user_info[:org_id]] do |survey|
          survey.organization_id == user_info[:org_id]
        end
      end
    end
  end
end
