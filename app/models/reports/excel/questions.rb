class Reports::Excel::Questions
  delegate :all, :to => :questions
  attr_reader :questions

  def initialize(survey, current_ability)
    @survey = survey
    @questions = survey.questions
    @ability = current_ability
  end

  def build(options = {})
    filter_private_questions(options)
    self
  end

  def filter_private_questions(options = {})
    disable_filtering = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(options[:disable_filtering])
    if disable_filtering
      @ability.authorize!(:change_excel_filters, @survey)
    else
      @questions = @questions.where("private != ?", true)
    end
    self
  end
end
