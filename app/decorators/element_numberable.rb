module ElementNumberable
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
