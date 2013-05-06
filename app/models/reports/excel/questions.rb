class Reports::Excel::Questions
  delegate :all, :to => :questions
  attr_reader :questions

  def initialize(survey)
    @questions = survey.questions
  end

  def build(options = {})
    if options[:filter_private_questions]
      @questions = @questions.where("private != ?", true)
    end
    self
  end
end
