class ResponseDecorator < Draper::Base
  decorates :response

  def sort_answers
    answer_ids = model.sorted_answers.map(&:id)
    model.answers.sort_by! { |answer| answer_ids.index(answer.id) || 0 }
  end
end
