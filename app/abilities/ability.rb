class Ability
  include CanCan::Ability

  def self.ability_for(user)
    return ViewerAbility.new(user) if user[:role] == 'viewer'
    return AdminAbility.new(user) if user[:role] == 'cso_admin'
    return Ability.new(user)
  end

  def initialize(user_info)
    @user_info = user_info
    #can :manage, :all
    can :read, Survey, :id => nil # The root_url is Surveys#index
  end

  def surveys_belonging_to_his_organization
    { :organization_id => @user_info[:org_id] }
  end


  def can_perform_on_own_and_shared_surveys(action)
    can action, Survey, sql_for_own_and_shared_surveys do |survey|
      survey.organization_id == @user_info[:org_id] || survey.participating_organizations.find_by_organization_id(@user_info[:org_id])
    end
  end

  private

  def sql_for_own_and_shared_surveys
    [
        'surveys.id in (SELECT "surveys".id FROM "surveys"
      LEFT OUTER JOIN participating_organizations ON participating_organizations.survey_id = surveys.id
      WHERE (surveys.organization_id = ? OR participating_organizations.organization_id = ?))',
        @user_info[:org_id], @user_info[:org_id]
    ]
  end
end
