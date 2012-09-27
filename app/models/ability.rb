class Ability
  include CanCan::Ability

  def initialize(user_info)

    if !user_info # guest user (not logged in)
      can :read, Survey do |survey|
        nil
      end
    else
      role = user_info[:role]
      if role == 'admin'
        can :manage, :all # TODO: Verify this
      elsif role == 'cso_admin'
        can :read, Survey, Survey.where('organization_id' => user_info[:org_id]) do |survey|
          survey.organization_id == user_info[:org_id]
        end
      elsif role == 'user'
        can :read, Survey, 
        Survey.joins(:survey_users).where('survey_users.user_id' => user_info[:user_id])
        .where('surveys.organization_id' => user_info[:org_id]) do |survey|
          SurveyUser.find_by_user_id_and_survey_id(user_info[:user_id], survey.id)
        end
      end
    end
  end
end
