class QuestionDecorator < Draper::Base
  decorates :question
  include ElementNumberable

  def input_tag(f, opts={})
    f.input (opts[:field] || :content), opts.merge(:label => label, :required => mandatory)
  end

  def label
    question_number + ")  " + content
  end

  def question_number
    if parent
      parent_question_number = "#{parent_question_decorator.question_number }"
      parent_question_number << option_number if multi_choice_parent
      index = ".#{sibling_elements.index(model) + 1}"
      parent_question_number + index
    else
      (sibling_elements.index(model) + 1).to_s
    end
  end

  private

  def parent_question_decorator
    QuestionDecorator.find(parent_question)
  end

  def option_number
    "#{(model.index_of_parent_option + 65).chr}"
  end

  def multi_choice_parent
    parent_question.is_a? MultiChoiceQuestion
  end
end
