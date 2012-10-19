class ResponseDecorator < Draper::Base
  decorates :response

  def render_question_with_sub_questions(question, f, level)
    question_view = input_tag_for(question, f)
    if question.respond_to?(:options)
      question.options.each do |option|
        option.questions.each do |sub_question|
          question_view += render_question_with_sub_questions(sub_question, f, level + 1)
        end
      end
    end
    h.content_tag :div, question_view, :class => 'question level-'+level.to_s
  end

  private

  def input_tag_for(question, f)
    case question.type
    when 'RadioQuestion'
      f.input :content, :label => question.content, :as => :radio, :collection => question.options.map(&:content), :required => question.mandatory

    when 'SingleLineQuestion'
      f.input :content, :label => question.content, :as => :string, :required => question.mandatory, :input_html => { :class => question.max_length ? "max_length" : nil, :data => { :max_length => question.max_length } }

    when 'MultilineQuestion'
      f.input :content, :label => question.content, :as => :text, :required => question.mandatory, :input_html => { :class => question.max_length ? "max_length" : nil, :data => { :max_length => question.max_length }, :rows => 4 }

    when 'NumericQuestion'
      has_range = question.max_value && question.min_value
      f.input :content, :label => question.content, :as => :number, :required => question.mandatory, :hint => numeric_question_hint(question.max_value, question.min_value)

    when 'DateQuestion'
      f.input :content, :label => question.content, :as => :string, :required => question.mandatory, :input_html => { :class => 'date' }

    when 'MultiChoiceQuestion'
      f.input :option_ids, :as => :check_boxes, :label => question.content, :required => question.mandatory, :collection => question.options.map(&:id), :member_label => Proc.new { |id| Option.find_by_id(id).try(:content)}

    when 'DropDownQuestion'
      f.input :content, :as => :select, :label => question.content, :required => question.mandatory, :collection => question.options.map(&:content)

    when 'PhotoQuestion'
      f.input :photo, :as => :file, :required => question.mandatory, :label => question.content

    when 'RatingQuestion'
      string = ERB.new "
      <div class='rating'>
        <%= f.label question.content %>
        <%= '<abbr>*</abbr>' if question.mandatory %>
        <%= f.input :content, :as => :hidden %>
        <div class='star'
            data-number-of-stars='<%= question.max_length %>'
            data-score='<%= Answer.find_by_question_id_and_response_id(question.id, id).content %>'>
        </div>
        <%= f.semantic_errors :content if (f.semantic_errors :content) %>
      </div>"

      string.result(binding).html_safe
    end
  end

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
