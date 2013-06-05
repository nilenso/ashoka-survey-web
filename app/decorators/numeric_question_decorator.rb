class NumericQuestionDecorator < QuestionDecorator
  decorates :numeric_question
  delegate_all

  def input_tag(f, opts={})
    super(f,  :as => :string,
              :hint => numeric_question_hint(model.min_value, model.max_value),
              :input_html => { :disabled => opts[:disabled] })
  end

  private

  def numeric_question_hint(min_value, max_value)
    return "The number should be between #{min_value} and #{max_value}" if min_value && max_value
    return "The number should is be less than #{max_value}" if max_value
    return "The number should is be greater than #{min_value}" if min_value
    nil
  end
end
