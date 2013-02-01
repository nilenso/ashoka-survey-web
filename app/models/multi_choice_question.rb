# A question with multiple options and multiple answers

class MultiChoiceQuestion < Question
  has_many :options, :dependent => :destroy,  :foreign_key => :question_id

  def report_data
    return [] if choices.blank?
    choice_ids = choices.map(&:option_id)
    options.map { |option| [option.content, choice_ids.count(option.id)] }
  end

  def with_sub_questions_in_order
    options.map(&:elements).flatten.map(&:with_sub_questions_in_order).flatten.unshift(self)
  end

  def sorted_answers_for_response(response_id, record_id=nil)
    options.map(&:elements).flatten.map { |element| element.sorted_answers_for_response(response_id, record_id) }.unshift(super).flatten
  end

  private

  def choices
    Choice.joins(:answer => :response).where(:responses => {:status => 'complete'}, :option_id => options.map(&:id))
  end
end
