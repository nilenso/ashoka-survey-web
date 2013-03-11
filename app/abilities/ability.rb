class Ability
  include CanCan::Ability

  def self.ability_for(user)
    return ViewerAbility.new(user) if user[:role] == 'viewer'
    return Ability.new(user)
  end

  def initialize(user_info)
    @user_info = user_info
    can :read, Survey, :id => nil # The root_url is Surveys#index
  end
end
