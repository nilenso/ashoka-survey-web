class NumericQuestion < Question
  attr_accessible  :max_value, :min_value

  validates_numericality_of :max_value, :min_value, :allow_nil => true
  validate :min_value_less_than_max_value

  def report_data
    answers_grouped_by_content = answers_for_reports.count(:group => 'answers.content')
    answers_grouped_by_content.map { |content,count| [content.to_f, count] }
  end

  def min_value_for_report
    min_value || 0
  end

  def max_value_for_report
    max_value || max_value_in_answers || 0
  end

  private

  def answers_content
    answers.complete.map(&:content)
  end

  def max_value_in_answers
   answers_content.map{ |answer| answer.to_f }.max
  end

  def min_value_less_than_max_value
    if min_value && max_value && (min_value > max_value)
      errors.add(:min_value, I18n.t('questions.validations.min_value_higher'))
    end
  end
end
