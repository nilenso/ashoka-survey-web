module ElementNumberable
  def question_number
    if parent
      parent_question_number = "#{parent_question_decorator.question_number }"
      parent_question_number << option_number if multi_choice_parent
      index = ".#{sibling_elements.index(model) + 1}"
      parent_question_number + index
    elsif category
      "#{parent_category_decorator.question_number}.#{sibling_elements.index(model) + 1}"
    else
      (sibling_elements.index(model) + 1).to_s
    end
  end

  private

  def parent_category_decorator
    CategoryDecorator.find(category)
  end

  def parent_question_decorator
    QuestionDecorator.find(parent_question)
  end

  def option_number
    "#{(model.index_of_parent_option + 65).chr}"
  end

  def multi_choice_parent
    parent_question.is_a? MultiChoiceQuestion
  end

  def sibling_elements
    if model_parent
      model_parent.elements_with_questions
    else
      survey.first_level_elements
    end
  end

  def model_parent
    parent || category
  end
end
