class SurveyDecorator < Draper::Decorator
  decorates :survey
  decorates_finders
  delegate_all
  self.include_root_in_json = false

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

  def organization
    Organization.find_by_id(context[:access_token], model.organization_id)
  end

  def organization_logo_url
    organization.logo_url
  end

  def report_data_for(question)
    header = [question.content, 'No. of Answers']
    report_data = question.report_data
    if report_data.present?
      h.escape_javascript(report_data.unshift(header).to_json.html_safe)
    else
      []
    end
  end

  def class_for_disabled
    model.finalized? ? '' : 'disabled'
  end

  def thank_you_message
    model.thank_you_message.blank? ?  h.t("publication.edit.thank_you_message") : model.thank_you_message
  end

  def public_url
    if model.public?
      h.survey_public_response_url(model.id) + "?auth_key=#{model.auth_key}"
    else
      h.survey_responses_url(model.id)
    end
  end

  def has_responses?
    model.responses.accessible_by(h.current_ability).count != 0
  end

  def as_json(opts = {})
    super.merge(:organization_logo_url => organization_logo_url)
  end

  private

  def template_tag(content, id)
    "<script type='text/template' id='#{id}'>#{content}</script>"
  end

  def template_types
    ['RadioQuestion', 'SingleLineQuestion', 'MultilineQuestion',
     'NumericQuestion', 'DateQuestion', 'MultiChoiceQuestion',
     'DropDownQuestion', 'PhotoQuestion', 'RatingQuestion', 'SurveyDetails',
     'MultiChoiceOption', 'RadioOption', 'DropDownOption', 'Category', 'MultiRecordCategory'
     ]
  end
end
