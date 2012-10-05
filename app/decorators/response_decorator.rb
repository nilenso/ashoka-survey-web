class ResponseDecorator < Draper::Base
  decorates :response

  def input_tag_for(question, f)
    if question.type == 'RadioQuestion'
      f.input :content, :label => question.content, :as => :radio, :collection => question.options.map(&:content), :required => question.mandatory

    elsif question.type == 'SingleLineQuestion'
      f.input :content, :label => question.content, :as => :string, :required => question.mandatory, :input_html => { :class => question.max_length ? "max_length" : nil, :data => { :max_length => question.max_length } }

    elsif question.type == 'MultilineQuestion'
      f.input :content, :label => question.content, :as => :text, :required => question.mandatory, :input_html => { :class => question.max_length ? "max_length" : nil, :data => { :max_length => question.max_length }, :rows => 4 }

    elsif question.type == 'NumericQuestion'
      has_range = question.max_value && question.min_value
      f.input :content, :label => question.content, :as => :number, :required => question.mandatory, :hint => numeric_question_hint(question.max_value, question.min_value)

    elsif question.type == 'DateQuestion'
      f.input :content, :label => question.content, :as => :string, :required => question.mandatory, :input_html => { :class => 'date' }

    elsif question.type == 'MultiChoiceQuestion'
      f.input :option_ids, :as => :check_boxes, :label => question.content, :required => question.mandatory, :collection => question.options.map(&:id), :member_label => method(:get_option_content_from_option_id)

    elsif question.type == 'DropDownQuestion'
      f.input :content, :as => :select, :label => question.content, :required => question.mandatory, :collection => question.options.map(&:content)

    elsif question.type == 'PhotoQuestion'
      f.input :photo, :as => :file, :required => question.mandatory, :label => question.content

    elsif question.type == 'RatingQuestion'
      string = ''
      string << "<div class='rating'>"
      string << (f.label question.content)
      string << "<abbr>*</abbr>" if question.mandatory
      string << (f.input :content, :as => :hidden)
      string << "<div class='star' data-number-of-stars='#{question.max_length}'></div>"
      string << (f.semantic_errors :content) if (f.semantic_errors :content)
      string << "</div>"
      string.html_safe
    end
  end
end
