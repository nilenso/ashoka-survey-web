class SuperAdminAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :manage, :all
  end
end
