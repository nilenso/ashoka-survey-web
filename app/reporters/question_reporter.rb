class QuestionReporter < QuestionDecorator
  delegate_all

  def header
    "#{question_number}) #{model.content}"
  end

  def formatted_answers_for(answers, options={})
    if answers
      answers.map { |answer| answer.content_for_excel(options[:server_url]) }.join(', ')
    else
      ""
    end
  end
end
