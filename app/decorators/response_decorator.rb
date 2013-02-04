class ResponseDecorator < Draper::Base
  decorates :response

  def self.question_number(question)
    if question.parent
      sibling_elements = (question.parent.questions + question.parent.categories_with_questions).sort_by(&:order_number)
      parent_question_number = "#{question_number(question.parent_question)}"
      parent_question_number += "#{(question.index_of_parent_option + 65).chr}" if (question.parent_question.is_a? MultiChoiceQuestion)
      index = ".#{sibling_elements.index(question) + 1}"
      parent_question_number + index
    elsif question.category
      sibling_elements = (question.category.questions + question.category.categories_with_questions).sort_by(&:order_number)
      "#{question_number(question.category)}.#{sibling_elements.index(question) + 1}"
    else
      sibling_elements = question.survey.first_level_elements
      (sibling_elements.index(question) + 1).to_s
    end
  end

  private


  def get_option_content_from_option_id(id)
    Option.find_by_id(id).try(:content)
  end
end
