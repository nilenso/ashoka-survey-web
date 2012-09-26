class SurveyUser < ActiveRecord::Base
  attr_accessible :survey_id, :user_id
  belongs_to :survey
end
