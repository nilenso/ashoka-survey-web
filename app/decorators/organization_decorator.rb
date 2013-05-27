class OrganizationDecorator < Draper::Base
  def survey_count
    Survey.where(:organization_id => model.id).count
  end

  def survey_count_in_words
    h.pluralize(survey_count, "Survey")
  end

  def response_count
    Response.where(:survey_id => Survey.where(:organization_id => model.id), :blank => false).count
  end

  def response_count_in_words
    h.pluralize(response_count, "Response")
  end

  def user_count
    Organization.users(context[:access_token], model.id).count
  end

  def user_count_in_words
    h.pluralize(user_count, "User")
  end
end
