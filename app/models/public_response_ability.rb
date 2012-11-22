class PublicResponseAbility < Ability
  def initialize(user_info)
    super
    can :read, Survey, :public => true
    can :manage, Response, :session_token => user_info[:session_token]
  end
end
