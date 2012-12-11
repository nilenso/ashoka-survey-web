class SurveyUser < ActiveRecord::Base
  attr_accessible :survey_id, :user_id
  belongs_to :survey
  validates_uniqueness_of :user_id, :scope => :survey_id
  validate :survey_finalized

  def survey_finalized
    errors.add(:survey, "is not finalized") unless survey.finalized?
  end
end
