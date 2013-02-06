class ResponseDecorator < Draper::Base
  decorates :response

  def sort_answers
    answer_ids = model.sorted_answers.map(&:id)
    model.answers.sort_by! { |answer| answer_ids.index(answer.id) || 0 }
  end

  private


  def get_option_content_from_option_id(id)
    Option.find_by_id(id).try(:content)
  end
end
