# A question with multiple options and multiple answers

class MultiChoiceQuestion < QuestionWithOptions
  def report_data
    return [] if choices.blank?
    choice_ids = choices.map(&:option_id)
    options.map { |option| [option.content, choice_ids.count(option.id)] }
  end

  def reporter
    MultiChoiceQuestionReporter.decorate(self)
  end

  private

  def choices
    Choice.joins(:answer => :response).where(:responses => {:status => 'complete', :state => 'clean'}, :option_id => options.map(&:id))
  end
end
