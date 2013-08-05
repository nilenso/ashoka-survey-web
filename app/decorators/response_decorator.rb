class ResponseDecorator < Draper::Decorator
  decorates :response
  decorates_finders
  delegate_all

  def sort_answers(answers)
    ids_of_questions_in_order = model.survey.ordered_question_tree.map(&:id)
    answers.sort_by { |answer| ids_of_questions_in_order.index(answer.question_id) || 0 }
  end
end
