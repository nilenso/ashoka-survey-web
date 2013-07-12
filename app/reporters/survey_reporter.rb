class SurveyReporter
  def initialize(survey)
    @survey = survey
  end

  def monthly_incomplete_responses_for(user_id)
    incomplete_hash = @survey.responses.where(:user_id => user_id, :status => Response::Status::INCOMPLETE).count(:group => "to_char(created_at, 'Mon YYYY')")
    incomplete = incomplete_hash.map {|month, count| ResponseCount.new(month, count, 0) }
    ResponseCounts.new(incomplete)
  end

  def monthly_complete_responses_for(user_id)
    complete_hash = @survey.responses.where(:user_id => user_id, :status => Response::Status::COMPLETE).count(:group => "to_char(completed_at, 'Mon YYYY')")
    complete = complete_hash.map {|month, count| ResponseCount.new(month, 0, count) }
    ResponseCounts.new(complete)
  end

  def response_counts_for(user_id)
    incomplete_counts = monthly_incomplete_responses_for(user_id)
    complete_counts = monthly_complete_responses_for(user_id)
    incomplete_counts.merge(complete_counts)
  end
end