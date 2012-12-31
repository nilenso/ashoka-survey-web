# A question with a single line answer

class NumericQuestion < Question
  attr_accessible  :max_value, :min_value
  validates_numericality_of :max_value, :min_value, :allow_nil => true
  validate :min_value_less_than_max_value

  def report_data
    answers_content = answers.map(&:content)
    answers_content.uniq.inject([]) do |data, content|
      data.push [content.to_i, answers_content.count(content)]
    end
  end

  def min_value_for_report
    min_value || 0
  end

  def max_value_for_report
    max_value || max_value_in_answers || 0
  end

  private

  def max_value_in_answers
    answers.map(&:content).compact.max
  end

  def min_value_less_than_max_value
    if min_value && max_value && (min_value > max_value)
      errors.add(:min_value, I18n.t('questions.validations.min_value_higher'))
    end
  end
end
