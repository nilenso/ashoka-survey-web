# Set of answers for a survey

class Response < ActiveRecord::Base
  belongs_to :survey
  has_many :answers, :dependent => :destroy
  accepts_nested_attributes_for :answers
  attr_accessible :survey, :answers_attributes, :mobile_id
  validates_presence_of :survey_id
  validates_presence_of :organization_id
  validates_presence_of :user_id

  def answers_for_identifier_questions
    answers.find_all { |answer| answer.question.identifier? }
  end

  def mark_complete
    self.update_attribute(:complete, true)
  end

  def mark_incomplete
    self.update_attribute(:complete, false)
  end

  def self.save_with_answers(answers_attributes, survey_id, user_id = 0, organization_id = 0)
    response = Response.new
    response.set(survey_id, user_id, organization_id)
    response.update_attributes(answers_attributes) if response.save
    response
  end

  
  def set(survey_id, user_id, organization_id)
    self.survey_id = survey_id
    self.organization_id = organization_id
    self.user_id = user_id
  end
end
