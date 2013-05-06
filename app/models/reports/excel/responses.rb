class Reports::Excel::Responses
  delegate :all, :to => :responses
  attr_reader :responses

  def initialize(responses)
    @responses = responses
  end

  def build(options={})
    options ||= {}
    completed.earliest_first.between(options[:from], options[:to])
    self
  end

  def completed
    @responses = @responses.completed
    self
  end

  def earliest_first
    @responses = @responses.earliest_first
    self
  end

  def between(from, to)
    @responses = @responses.created_between(from, to) if from.present? && to.present?
    self
  end
end
