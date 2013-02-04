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


  def category_name_for(category)
    @categories ||= []
    return "" unless category
    unless @categories.include?(category.id)
      @categories << category.id

      string = ERB.new "
        <%= category_name_for(category.category) %>
        <div class='category <%= 'hidden sub_question' if category.sub_question? %>'
             data-nesting-level='<%= category.nesting_level %>'
             data-parent-id='<%= category.parent_id %>'
             data-id='<%= category.id %>'
             data-category-id='<%= category.category_id %>'>
          <h2>
            <%= ResponseDecorator.question_number(category) %>)
            <%= category.content %>
            <%= category.decorate.create_record_link(model.id) %>
          </h2>
        </div>
      "
      string.result(binding).force_encoding('utf-8').html_safe
    end
  end

  private


  def get_option_content_from_option_id(id)
    Option.find_by_id(id).try(:content)
  end
end
