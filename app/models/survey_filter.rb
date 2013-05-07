class SurveyFilter
  attr_reader :surveys, :survey_filter
  def initialize(surveys, survey_filter)
    @surveys = surveys
    @survey_filter = survey_filter
  end

  def filter
    case survey_filter
    when "drafts"
      surveys.drafts
    when "archived"
      surveys.archived
    when "expired"
      surveys.unarchived.expired
    else
      surveys.active
    end
  end
end
