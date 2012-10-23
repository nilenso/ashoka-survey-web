# Set of answers for a survey

class Response < ActiveRecord::Base
  belongs_to :survey
  has_many :answers, :dependent => :destroy
  accepts_nested_attributes_for :answers
  attr_accessible :survey, :answers_attributes, :mobile_id, :survey_id
  validates_presence_of :survey_id
  validates_presence_of :organization_id
  validates_presence_of :user_id
  validates_associated :answers

  def answers_for_identifier_questions
    answers.find_all { |answer| answer.question.identifier? }
  end

  def complete
    self.update_attribute(:status, 'complete')
  end

  def incomplete
    self.update_attribute(:status, 'incomplete')
  end

  def validating
    self.update_attribute(:status, 'validating')
  end

  def complete?
    status == 'complete'
  end

  def validating?
    status == 'validating'
  end
  
  def set(survey_id, user_id, organization_id)
    self.survey_id = survey_id
    self.organization_id = organization_id
    self.user_id = user_id
  end
end
