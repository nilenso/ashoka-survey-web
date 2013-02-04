# A question with multiple options and multiple answers

class MultiChoiceQuestion < QuestionWithOptions
  def report_data
    return [] if choices.blank?
    choice_ids = choices.map(&:option_id)
    options.map { |option| [option.content, choice_ids.count(option.id)] }
  end

  private

  def choices
    Choice.joins(:answer => :response).where(:responses => {:status => 'complete'}, :option_id => options.map(&:id))
  end
end
