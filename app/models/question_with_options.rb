class QuestionWithOptions < Question
  has_many :options, :dependent => :destroy,  :foreign_key => :question_id

  alias_method :serializable_options, :options

  def create_blank_answers(params={})
    super
    options.map(&:elements).flatten.each { |element| element.create_blank_answers(params) }
  end

  def report_data
    return [] if no_answers?
    answers = super
    options.map { |option| [option.content, option.report_data(answers)] }
  end

  def sorted_answers_for_response(response_id, record_id=nil)
    options.map(&:elements).flatten.map { |element| element.sorted_answers_for_response(response_id, record_id) }.unshift(super).flatten
  end

  def as_json_with_elements_in_order
    json = self.as_json(:methods => 'type')
    json['options'] = options.includes(:questions).map(&:as_json_with_elements_in_order).flatten
    json
  end

  def questions_in_order
    [self, options.map(&:questions_in_order)].flatten
  end

  private
  def no_answers?
    answers.joins(:response).where(:responses => {:status => 'complete'}).count == 0
  end
end
