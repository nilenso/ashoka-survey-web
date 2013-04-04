class FinancialInstituteAbility < Ability
  def initialize(user_info)
    @user_info = user_info
    can_perform_on_own_and_shared_surveys(:read)
    can_perform_on_own_and_shared_surveys(:generate_excel)

    can :read, Response, :survey => { :participating_organizations => { :organization_id => user_info[:org_id ] } }
    can :count, Response
  end
end
