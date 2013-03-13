class ViewerAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can_perform_on_own_and_shared_surveys(:read)
    can_perform_on_own_and_shared_surveys(:report)

    can :read, Response, :survey => { :organization_id => user_info[:org_id] }
    can :read, Response, :organization_id => user_info[:org_id]
  end
end
