class DropDownQuestion < Question
  has_many :options, :dependent => :destroy, :foreign_key => :question_id

  def with_sub_questions_in_order
    options.map(&:questions).flatten.map(&:with_sub_questions_in_order).flatten.unshift(self)
  end

  def report_data
    return [] if answers.select { |answer| answer.response.complete? }.blank?
    options.map { |option| [option.content, option.report_data] }
  end
end