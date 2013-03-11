class ViewerAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :read, Survey, :organization_id => user_info[:org_id]
    can :questions_count, Survey, :organization_id => user_info[:org_id]
    can :read, Category, :survey => { :organization_id => user_info[:org_id] }
    can :read, Question, :survey => { :organization_id => user_info[:org_id] }
    can :read, Option, :question => { :survey => { :organization_id => user_info[:org_id] } }
  end
end
