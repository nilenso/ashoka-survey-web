class DesignerAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :create, Survey, :organization_id => user_info[:org_id]
    can :build, Survey, :organization_id => user_info[:org_id]
    can :update, Survey, :organization_id => user_info[:org_id]
    can :destroy, Survey, :organization_id => user_info[:org_id]
    can :duplicate, Survey, :organization_id => user_info[:org_id]
    can :read, Survey, :organization_id => user_info[:org_id]
    can :report, Survey, :organization_id => user_info[:org_id]
    can :finalize, Survey, :organization_id => user_info[:org_id]

    can :edit_publication, Survey, :organization_id => user_info[:org_id]
    can :update_publication, Survey, :organization_id => user_info[:org_id]


    can :manage, Response, :survey => { :organization_id => user_info[:org_id] }
    can :manage, Response, :organization_id => user_info[:org_id]
    cannot :destroy, Response, :survey => { :organization_id => user_info[:org_id] }
    cannot :destroy, Response, :organization_id => user_info[:org_id]
  end
end
