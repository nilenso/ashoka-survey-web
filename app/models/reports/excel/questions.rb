class Reports::Excel::Questions
  delegate :all, :to => :questions
  attr_reader :questions

  def initialize(survey)
    @questions = survey.questions
  end

  def build(options = {})
    filter_private_questions = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(options[:filter_private_questions])
    if filter_private_questions
      @questions = @questions.where("private != ?", true)
    end
    self
  end
end
