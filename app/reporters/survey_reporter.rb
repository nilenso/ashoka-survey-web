class SurveyReporter
  def initialize(survey)
    @survey = survey
  end

  def incomplete_responses_per_survey_per_user_grouped_by_month(user_id)
    @survey.responses.where(:user_id => user_id, :status => Response::Status::INCOMPLETE).count(:group => "to_char(created_at, 'Mon YYYY')")
  end

  def complete_responses_per_survey_per_user_grouped_by_completion_month(user_id)
    @survey.responses.where(:user_id => user_id, :status => Response::Status::COMPLETE).count(:group => "to_char(completed_at, 'Mon YYYY')")
  end
end