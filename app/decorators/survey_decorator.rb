class SurveyDecorator < Draper::Base
  decorates :survey

  def build_mustache_templates
    template_types.inject('') do |string, type|
      string << template_tag(h.render("/templates/questions/#{type.underscore}"), "#{type.underscore}_template")
      string << template_tag(h.render("/templates/dummies/#{type.underscore}"), "dummy_#{type.underscore}_template")
    end.html_safe
  end

  def more_less_links
    if model.description.try(:length).try(:>, 120)
      h.link_to(h.translate(".more"), '#', :class => 'more_description_link') +
        h.link_to(h.translate(".less"), '#', :class => 'less_description_link')
    end
  end

  def organization_name(organizations)
    organizations.find { |org| org.id == model.organization_id }.try(:name)
  end

  def report_data_for(question)
    header = [question.content, 'Answer / Count']
    question.report_data.unshift(header).to_json.html_safe
  end

  def class_for_disabled
    model.finalized? ? '' : 'disabled'
  end

  def public_url
    if survey.public?
      h.survey_public_response_url(model.id) + "?auth_key=#{model.auth_key}"
    else
      h.survey_responses_url(model.id)
    end
  end

  private

  def template_tag(content, id)
    "<script type='text/template' id='#{id}'>#{content}</script>"
  end

  def template_types
    ['RadioQuestion', 'SingleLineQuestion', 'MultilineQuestion',
     'NumericQuestion', 'DateQuestion', 'MultiChoiceQuestion',
     'DropDownQuestion', 'PhotoQuestion', 'RatingQuestion', 'SurveyDetails',
     'MultiChoiceOption', 'RadioOption', 'DropDownOption', 'Category'
     ]
  end
end
