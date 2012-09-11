module ResponsesHelper
  def numeric_question_hint(min_value, max_value)
    return "The number should be between #{min_value} and #{max_value}" if min_value && max_value
    return "The number should is be greater than #{max_value}" if max_value
    return "The number should is be less than #{min_value}" if min_value
    nil
  end
end
