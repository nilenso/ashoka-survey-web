class AdminAbility < Ability
  def initialize(user_info)
    @user_info = user_info
    can :manage, :all # Need this to pass specs until we have the actual abilities here
  end
end
