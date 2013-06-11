class PublicAbility < Ability
  def initialize(user_info)
    super
    can :read, Survey, :public => true
    can :manage, Response, :session_token => user_info[:session_token]
    cannot :destroy, Response
    cannot :read, Response
  end
end
