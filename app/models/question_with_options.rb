class QuestionWithOptions < Question
  has_many :options, :dependent => :destroy,  :foreign_key => :question_id

  alias_method :serializable_options, :options

  def create_blank_answers(params={})
    super
    options.map(&:elements).flatten.each { |element| element.create_blank_answers(params) }
  end

  def report_data
    answers = answers_for_reports
    report_data = options.map { |option| [option.content, option.report_data(answers)] }
    if report_data.map { |option, count| count }.uniq == [0]
      []
    else
      report_data
    end
  end

  def sorted_answers_for_response(response_id, record_id=nil)
    options.map(&:elements).flatten.map { |element| element.sorted_answers_for_response(response_id, record_id) }.unshift(super).flatten
  end

  def as_json_with_elements_in_order
    json = self.as_json(:methods => 'type')
    json['options'] = options.ascending.includes(:questions).map(&:as_json_with_elements_in_order).flatten
    json
  end

  def ordered_question_tree
    [self, options.ascending.map(&:ordered_question_tree)].flatten
  end
end
