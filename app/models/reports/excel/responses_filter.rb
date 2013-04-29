class Reports::Excel::ResponsesFilter
  def initialize(responses)
    @responses = responses
    filter
  end

  def filter
    @responses.completed.earliest_first
  end
end
