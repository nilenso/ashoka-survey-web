class SupervisorAbility < Ability
  def initialize(user_info)
    @user_info = user_info

    can :read, Survey, surveys_published_to_me
    can :report, Survey, surveys_published_to_me
    can :archive, Survey, surveys_published_to_me
    can :generate_excel, Survey, surveys_published_to_me
    can :view_survey_dashboard, Survey, surveys_published_to_me

    can_perform_on_responses_of_surveys_published_to_me(:manage)
  end
  
  private

  def surveys_published_to_me
    { :survey_users => { :user_id => @user_info[:user_id] } }
  end

  def can_perform_on_responses_of_surveys_published_to_me(action)
    can action, Response, sql_for_responses_of_surveys_published_to_me do |response|
      SurveyUser.find_by_user_id_and_survey_id(@user_info[:user_id], response.survey_id).present?
    end
  end

  def sql_for_responses_of_surveys_published_to_me
    [
        'responses.survey_id IN (SELECT survey_users.survey_id from survey_users
         WHERE survey_users.user_id = ?)', @user_info[:user_id]
    ]
  end
end
