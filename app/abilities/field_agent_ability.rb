class FieldAgentAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :read, Survey, :survey_users => { :user_id => user_info[:user_id] }
    can :report, Survey, :survey_users => { :user_id => user_info[:user_id] }
    can :generate_excel, Survey, :survey_users => { :user_id => user_info[:user_id] }
    can :create, Response, :survey => { :survey_users => { :user_id => user_info[:user_id] } }
    can :manage, Response, :user_id => user_info[:user_id]
    cannot :destroy, Response
    cannot :provide_state, Response
  end
end
