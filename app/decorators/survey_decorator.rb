class SurveyDecorator < Draper::Base
  decorates :survey

  def build_mustache_templates
    template_types.inject('') do |string, type|
      string << template_tag(h.render("/templates/questions/#{type.underscore}"), "#{type.underscore}_template")
      string << template_tag(h.render("/templates/dummies/#{type.underscore}"), "dummy_#{type.underscore}_template")
    end.html_safe
  end

  private

  def template_tag(content, id)
    "<script type='text/template' id='#{id}'>#{content}</script>"
  end

  def template_types
    ['RadioQuestion', 'SingleLineQuestion', 'MultilineQuestion',
     'NumericQuestion', 'DateQuestion', 'MultiChoiceQuestion',
     'DropDownQuestion', 'PhotoQuestion', 'RatingQuestion', 'SurveyDetails',
     'MultiChoiceOption', 'RadioOption', 'DropDownOption'
     ]
  end
end
