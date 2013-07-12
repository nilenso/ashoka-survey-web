class SurveyReporter
  def initialize(survey)
    @survey = survey
  end

  def monthly_incomplete_responses_for(user_id)
    @survey.responses.where(:user_id => user_id, :status => Response::Status::INCOMPLETE).count(:group => "to_char(created_at, 'Mon YYYY')")
  end

  def monthly_complete_responses_for(user_id)
    @survey.responses.where(:user_id => user_id, :status => Response::Status::COMPLETE).count(:group => "to_char(completed_at, 'Mon YYYY')")
  end

  def response_counts_for(user_id)
    incomplete_count = monthly_incomplete_responses_for(user_id)
    complete_count = monthly_complete_responses_for(user_id)
    by_month = (incomplete_count.keys + complete_count.keys).uniq.map do |key|
      [key, { Response::Status::INCOMPLETE => incomplete_count[key] || 0,
              Response::Status::COMPLETE => complete_count[key] || 0 }]
    end
    Hash[by_month]
  end
end