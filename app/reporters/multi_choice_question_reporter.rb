class MultiChoiceQuestionReporter < QuestionReporter
  def header
    [super] + question.options.map(&:content)
  end

  def formatted_answers_for(answers, options={})
    option_selections = model.options.map do |option|
      choices = Choice.where('answer_id in (?) AND option_id = ?', answers.map(&:id), option.id)
      if choices.present?
        answers.map { "YES" }.join(", ") # Need to join in case we're in a Multi-Record
      else
        answers.map { "NO" }.join(", ")
      end
    end
    [""] + option_selections
  end
end
