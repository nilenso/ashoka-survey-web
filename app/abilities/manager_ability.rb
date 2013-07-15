class ManagerAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :create, Survey, :organization_id => user_info[:org_id]
    can :build, Survey, :organization_id => user_info[:org_id]
    can :update, Survey, :organization_id => user_info[:org_id]
    can :destroy, Survey, :organization_id => user_info[:org_id]
    can :archive, Survey, :organization_id => user_info[:org_id]
    can :finalize, Survey, :organization_id => user_info[:org_id]
    can :view_survey_dashboard, Survey, :organization_id => user_info[:org_id]

    can_perform_on_own_and_shared_surveys(:duplicate)
    can_perform_on_own_and_shared_surveys(:read)
    can_perform_on_own_and_shared_surveys(:report)
    can_perform_on_own_and_shared_surveys(:generate_excel)

    can :manage, Response, :survey => { :organization_id => user_info[:org_id] }
    can :manage, Response, :organization_id => user_info[:org_id]
    can :create, Response, :survey => { :participating_organizations => { :organization_id => user_info[:org_id] } }

    can_perform_on_own_and_shared_surveys(:edit_publication)
    can_perform_on_own_and_shared_surveys(:update_publication)
    can_perform_on_own_and_shared_surveys(:change_excel_filters)
  end
end
