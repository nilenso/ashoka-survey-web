class ResponseDecorator < Draper::Base
  decorates :response

  def input_tag_for(question, f, disabled)
    case question.type
    when 'RadioQuestion'
      f.input :content, :label => label_for(question), :as => :radio, :collection => question.options.map { |o| [o.content, o.content, {:data => { :option_id => o.id } }] }, :required => question.mandatory, :input_html => { :disabled => disabled }

    when 'DropDownQuestion'
      f.input :content, :as => :select, :label => label_for(question), :required => question.mandatory, :collection => question.options.map { |o| [o.content, o.content, {'data-option-id' => o.id }] }, :input_html => { :disabled => disabled }

    when 'SingleLineQuestion'
      f.input :content, :label => label_for(question), :as => :string, :required => question.mandatory, :input_html => { :disabled => disabled, :class => question.max_length ? "max_length" : nil, :data => { :max_length => question.max_length } }

    when 'MultilineQuestion'
      f.input :content, :label => label_for(question), :as => :text, :required => question.mandatory, :input_html => { :disabled => disabled, :class => question.max_length ? "max_length" : nil, :data => { :max_length => question.max_length }, :rows => 4 }

    when 'NumericQuestion'
      f.input :content, :label => label_for(question), :as => :number, :required => question.mandatory, :hint => numeric_question_hint(question.min_value, question.max_value), :input_html => { :disabled => disabled }

    when 'DateQuestion'
      f.input :content, :label => label_for(question), :as => :string, :required => question.mandatory, :input_html => { :disabled => disabled, :class => 'date' }

    when 'MultiChoiceQuestion'
      f.input :option_ids, :as => :check_boxes, :label => label_for(question), :required => question.mandatory, :collection => question.options.map(&:id), :member_label => Proc.new { |id| Option.find_by_id(id).try(:content)}, :disabled => disabled ? question.options.map(&:id) : []

    when 'PhotoQuestion'
      answer = Answer.find_by_question_id_and_response_id(question.id, id)
      "#{(h.image_tag answer.photo_url(:medium), :class => 'medium' if answer.photo_url.present?)} #{(f.input :photo, :as => :file, :required => question.mandatory, :label => label_for(question), :input_html => { :disabled => disabled })}".html_safe

    when 'RatingQuestion'
      string = ERB.new "
      <div class='rating'>
        <%= f.label label_for(question) %>
        <%= '<abbr>*</abbr>' if question.mandatory %>
        <%= f.input :content, :as => :hidden %>
        <div class='star'
            data-number-of-stars='<%= question.max_length %>'
            data-score='<%= Answer.find_by_question_id_and_response_id(question.id, id).content %>'>
        </div>
        <%= f.semantic_errors :content if (f.semantic_errors :content) %>
      </div>"

      string.result(binding).force_encoding('utf-8').html_safe
    end
  end

  def label_for(question)
    ResponseDecorator.question_number(question) + ")  " + question.content
  end

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

  def numeric_question_hint(min_value, max_value)
    return "The number should be between #{min_value} and #{max_value}" if min_value && max_value
    return "The number should is be greater than #{max_value}" if max_value
    return "The number should is be less than #{min_value}" if min_value
    nil
  end

  def get_option_content_from_option_id(id)
    Option.find_by_id(id).try(:content)
  end
end
