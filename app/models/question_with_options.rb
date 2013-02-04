class QuestionWithOptions < Question
  has_many :options, :dependent => :destroy,  :foreign_key => :question_id

  def create_blank_answers(params={})
    super
    options.map(&:elements).flatten.each { |element| element.create_blank_answers(params) }
  end

  def report_data
    return [] if no_answers?
    options.map { |option| [option.content, option.report_data] }
  end

  def sorted_answers_for_response(response_id, record_id=nil)
    options.map(&:elements).flatten.map { |element| element.sorted_answers_for_response(response_id, record_id) }.unshift(super).flatten
  end

  def with_sub_questions_in_order
    options.map(&:elements).flatten.map(&:with_sub_questions_in_order).flatten.unshift(self)
  end


  private
  def no_answers?
    answers.joins(:response).where(:responses => {:status => 'complete'}).count == 0
  end
end
