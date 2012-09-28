class SurveyUser < ActiveRecord::Base
  attr_accessible :survey_id, :user_id
  belongs_to :survey
  validates_uniqueness_of :user_id, :scope => :survey_id 
end
