# A piece of information for a question

class Answer < ActiveRecord::Base
  belongs_to :question
  attr_accessible :content, :question_id
  validate :mandatory_questions_should_be_answered
  validate :content_should_not_exceed_max_length

  private

  def mandatory_questions_should_be_answered
    if content.blank? && question.mandatory
      errors.add(:content, I18n.t('answers.validations.mandatory_question'))
    end
  end

  def content_should_not_exceed_max_length
  	if question.max_length && content.length > question.max_length
  		errors.add(:content, "Maximum length exceeded")
  	end
  end
end
