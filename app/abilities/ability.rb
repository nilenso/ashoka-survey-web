class Ability
  include CanCan::Ability

  def self.ability_for(user)
    return ViewerAbility.new(user) if user[:role] == 'viewer'
  end
end
